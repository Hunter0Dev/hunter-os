use gtk::prelude::*;
use gtk::{
    Application, ApplicationWindow, Box, Label, ListBox, Orientation, 
    ScrolledWindow, Separator, Notebook, Frame, Grid
};
use sysinfo::{System, SystemExt, ProcessExt, CpuExt, DiskExt, NetworkExt, NetworksExt};
use std::cell::RefCell;
use std::rc::Rc;
use std::fs;

const APP_ID: &str = "org.hunteros.SystemMonitor";

fn main() {
    let app = Application::builder()
        .application_id(APP_ID)
        .build();

    app.connect_activate(build_ui);
    app.run();
}

fn build_ui(app: &Application) {
    // Create system info object
    let sys = Rc::new(RefCell::new(System::new_all()));
    
    // Main window
    let window = ApplicationWindow::builder()
        .application(app)
        .title("Hunter System Monitor")
        .default_width(1100)
        .default_height(750)
        .build();

    // Main container
    let main_box = Box::new(Orientation::Vertical, 0);

    // Create tabbed notebook (like Windows Task Manager)
    let notebook = Notebook::new();
    notebook.set_tab_pos(gtk::PositionType::Top);

    // Tab 1: Processes (Overview)
    let processes_tab = create_processes_tab(&sys);
    let processes_label = Label::new(Some("Processes"));
    notebook.append_page(&processes_tab, Some(&processes_label));

    // Tab 2: Performance (Detailed stats)
    let performance_tab = create_performance_tab(&sys);
    let performance_label = Label::new(Some("Performance"));
    notebook.append_page(&performance_tab, Some(&performance_label));

    // Tab 3: Details (Full process list)
    let details_tab = create_details_tab(&sys);
    let details_label = Label::new(Some("Details"));
    notebook.append_page(&details_tab, Some(&details_label));

    main_box.append(&notebook);
    window.set_child(Some(&main_box));
    window.present();

    // Update every 2 seconds
    let sys_clone = sys.clone();
    glib::timeout_add_seconds_local(2, move || {
        sys_clone.borrow_mut().refresh_all();
        glib::ControlFlow::Continue
    });
}

// ============================================
// Helper Functions
// ============================================

fn get_cpu_model_name() -> String {
    if let Ok(content) = fs::read_to_string("/proc/cpuinfo") {
        for line in content.lines() {
            if line.starts_with("model name") {
                if let Some(name) = line.split(':').nth(1) {
                    return name.trim().to_string();
                }
            }
        }
    }
    "Unknown CPU".to_string()
}

fn get_gpu_info() -> Vec<String> {
    let mut gpus = Vec::new();
    
    // Try NVIDIA
    if let Ok(nvml) = nvml_wrapper::Nvml::init() {
        if let Ok(device_count) = nvml.device_count() {
            for i in 0..device_count {
                if let Ok(device) = nvml.device_by_index(i) {
                    if let Ok(name) = device.name() {
                        let mut info = name.clone();
                        
                        // Add utilization
                        if let Ok(util) = device.utilization_rates() {
                            info.push_str(&format!(" ({}%", util.gpu));
                            if let Ok(temp) = device.temperature(nvml_wrapper::enum_wrappers::device::TemperatureSensor::Gpu) {
                                info.push_str(&format!(", {}°C", temp));
                            }
                            info.push(')');
                        }
                        
                        gpus.push(info);
                    }
                }
            }
        }
    }
    
    // Try AMD/Intel via sysfs
    if gpus.is_empty() {
        if let Ok(entries) = fs::read_dir("/sys/class/drm") {
            for entry in entries.flatten() {
                let path = entry.path();
                if let Some(name) = path.file_name() {
                    let name_str = name.to_string_lossy();
                    if name_str.starts_with("card") && !name_str.contains('-') {
                        let device_path = path.join("device/vendor");
                        if device_path.exists() {
                            if let Ok(vendor) = fs::read_to_string(&device_path) {
                                let vendor = vendor.trim();
                                let gpu_name = match vendor {
                                    "0x1002" => "AMD Radeon Graphics",
                                    "0x8086" => "Intel Integrated Graphics",
                                    "0x10de" => "NVIDIA Graphics",
                                    _ => "Unknown GPU"
                                };
                                gpus.push(gpu_name.to_string());
                                break;
                            }
                        }
                    }
                }
            }
        }
    }
    
    if gpus.is_empty() {
        gpus.push("No GPU detected".to_string());
    }
    
    gpus
}

// ============================================
// TAB 1: PROCESSES (Overview)
// ============================================

fn create_processes_tab(sys: &Rc<RefCell<System>>) -> Box {
    let tab_box = Box::new(Orientation::Vertical, 10);
    tab_box.set_margin_top(10);
    tab_box.set_margin_bottom(10);
    tab_box.set_margin_start(10);
    tab_box.set_margin_end(10);

    // System summary at top
    let summary_frame = Frame::new(Some("System"));
    let summary_box = Box::new(Orientation::Vertical, 5);
    summary_box.set_margin_top(10);
    summary_box.set_margin_bottom(10);
    summary_box.set_margin_start(10);
    summary_box.set_margin_end(10);

    let sys_ref = sys.borrow();
    
    // CPU info
    let cpu_model = get_cpu_model_name();
    let cpu_label = Label::new(None);
    cpu_label.set_markup(&format!("<b>CPU:</b> {}", cpu_model));
    cpu_label.set_xalign(0.0);
    summary_box.append(&cpu_label);

    // GPU info
    let gpus = get_gpu_info();
    for gpu in gpus {
        let gpu_label = Label::new(None);
        gpu_label.set_markup(&format!("<b>GPU:</b> {}", gpu));
        gpu_label.set_xalign(0.0);
        summary_box.append(&gpu_label);
    }

    // Resource usage
    let cpu_usage = sys_ref.global_cpu_info().cpu_usage();
    let total_mem = sys_ref.total_memory() as f64 / 1024.0 / 1024.0;
    let used_mem = sys_ref.used_memory() as f64 / 1024.0 / 1024.0;
    let mem_percent = (used_mem / total_mem) * 100.0;

    let usage_label = Label::new(None);
    usage_label.set_markup(&format!(
        "<b>CPU:</b> {:.1}%    <b>Memory:</b> {:.0} MB / {:.0} MB ({:.1}%)",
        cpu_usage, used_mem, total_mem, mem_percent
    ));
    usage_label.set_xalign(0.0);
    summary_box.append(&usage_label);

    summary_frame.set_child(Some(&summary_box));
    tab_box.append(&summary_frame);

    // Top processes
    let processes_frame = Frame::new(Some("Top Processes"));
    let process_scroll = create_top_processes_list(sys);
    processes_frame.set_child(Some(&process_scroll));
    tab_box.append(&processes_frame);

    tab_box
}

fn create_top_processes_list(sys: &Rc<RefCell<System>>) -> ScrolledWindow {
    let scroll = ScrolledWindow::builder()
        .hscrollbar_policy(gtk::PolicyType::Never)
        .vexpand(true)
        .build();
    
    let list_box = ListBox::new();
    let sys_ref = sys.borrow();
    
    // Header
    let header = Box::new(Orientation::Horizontal, 10);
    header.set_margin_start(5);
    
    let name_label = Label::new(None);
    name_label.set_markup("<b>Name</b>");
    name_label.set_width_chars(40);
    name_label.set_xalign(0.0);
    
    let cpu_label = Label::new(None);
    cpu_label.set_markup("<b>CPU</b>");
    cpu_label.set_width_chars(10);
    cpu_label.set_xalign(0.0);
    
    let mem_label = Label::new(None);
    mem_label.set_markup("<b>Memory</b>");
    mem_label.set_width_chars(15);
    mem_label.set_xalign(0.0);
    
    header.append(&name_label);
    header.append(&cpu_label);
    header.append(&mem_label);
    list_box.append(&header);
    
    // Top 15 processes
    let mut processes: Vec<_> = sys_ref.processes().iter().collect();
    processes.sort_by(|a, b| {
        b.1.cpu_usage().partial_cmp(&a.1.cpu_usage()).unwrap()
    });
    
    for (_, process) in processes.iter().take(15) {
        let row = Box::new(Orientation::Horizontal, 10);
        row.set_margin_start(5);
        
        let name_label = Label::new(Some(process.name()));
        name_label.set_width_chars(40);
        name_label.set_xalign(0.0);
        name_label.set_ellipsize(gtk::pango::EllipsizeMode::End);
        
        let cpu_label = Label::new(Some(&format!("{:.1}%", process.cpu_usage())));
        cpu_label.set_width_chars(10);
        cpu_label.set_xalign(0.0);
        
        let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
        let mem_label = Label::new(Some(&format!("{:.1} MB", mem_mb)));
        mem_label.set_width_chars(15);
        mem_label.set_xalign(0.0);
        
        row.append(&name_label);
        row.append(&cpu_label);
        row.append(&mem_label);
        list_box.append(&row);
    }
    
    scroll.set_child(Some(&list_box));
    scroll
}

// ============================================
// TAB 2: PERFORMANCE (Detailed Stats)
// ============================================

fn create_performance_tab(sys: &Rc<RefCell<System>>) -> Box {
    let tab_box = Box::new(Orientation::Vertical, 10);
    tab_box.set_margin_top(10);
    tab_box.set_margin_bottom(10);
    tab_box.set_margin_start(10);
    tab_box.set_margin_end(10);

    let sys_ref = sys.borrow();

    // CPU Section
    let cpu_frame = Frame::new(Some("CPU"));
    let cpu_grid = Grid::new();
    cpu_grid.set_margin_top(10);
    cpu_grid.set_margin_bottom(10);
    cpu_grid.set_margin_start(10);
    cpu_grid.set_margin_end(10);
    cpu_grid.set_row_spacing(10);
    cpu_grid.set_column_spacing(20);

    let cpu_model = get_cpu_model_name();
    let cpu_usage = sys_ref.global_cpu_info().cpu_usage();
    let cpu_cores = sys_ref.cpus().len();

    add_grid_row(&cpu_grid, 0, "Processor:", &cpu_model);
    add_grid_row(&cpu_grid, 1, "Utilization:", &format!("{:.1}%", cpu_usage));
    add_grid_row(&cpu_grid, 2, "Cores:", &format!("{}", cpu_cores));
    add_grid_row(&cpu_grid, 3, "Logical processors:", &format!("{}", cpu_cores));

    cpu_frame.set_child(Some(&cpu_grid));
    tab_box.append(&cpu_frame);

    // Memory Section
    let mem_frame = Frame::new(Some("Memory"));
    let mem_grid = Grid::new();
    mem_grid.set_margin_top(10);
    mem_grid.set_margin_bottom(10);
    mem_grid.set_margin_start(10);
    mem_grid.set_margin_end(10);
    mem_grid.set_row_spacing(10);
    mem_grid.set_column_spacing(20);

    let total_mem = sys_ref.total_memory() as f64 / 1024.0 / 1024.0;
    let used_mem = sys_ref.used_memory() as f64 / 1024.0 / 1024.0;
    let available_mem = total_mem - used_mem;
    let mem_percent = (used_mem / total_mem) * 100.0;

    add_grid_row(&mem_grid, 0, "In use:", &format!("{:.0} MB ({:.1}%)", used_mem, mem_percent));
    add_grid_row(&mem_grid, 1, "Available:", &format!("{:.0} MB", available_mem));
    add_grid_row(&mem_grid, 2, "Total:", &format!("{:.0} MB", total_mem));

    mem_frame.set_child(Some(&mem_grid));
    tab_box.append(&mem_frame);

    // Disk Section
    let disk_frame = Frame::new(Some("Disk"));
    let disk_box = create_disk_details(sys);
    disk_frame.set_child(Some(&disk_box));
    tab_box.append(&disk_frame);

    // GPU Section
    let gpu_frame = Frame::new(Some("GPU"));
    let gpu_box = Box::new(Orientation::Vertical, 5);
    gpu_box.set_margin_top(10);
    gpu_box.set_margin_bottom(10);
    gpu_box.set_margin_start(10);
    gpu_box.set_margin_end(10);

    let gpus = get_gpu_info();
    for gpu in gpus {
        let gpu_label = Label::new(Some(&gpu));
        gpu_label.set_xalign(0.0);
        gpu_box.append(&gpu_label);
    }

    gpu_frame.set_child(Some(&gpu_box));
    tab_box.append(&gpu_frame);

    tab_box
}

fn add_grid_row(grid: &Grid, row: i32, label: &str, value: &str) {
    let label_widget = Label::new(Some(label));
    label_widget.set_xalign(0.0);
    label_widget.set_markup(&format!("<b>{}</b>", label));
    
    let value_widget = Label::new(Some(value));
    value_widget.set_xalign(0.0);
    
    grid.attach(&label_widget, 0, row, 1, 1);
    grid.attach(&value_widget, 1, row, 1, 1);
}

fn create_disk_details(sys: &Rc<RefCell<System>>) -> Box {
    let disk_box = Box::new(Orientation::Vertical, 5);
    disk_box.set_margin_top(10);
    disk_box.set_margin_bottom(10);
    disk_box.set_margin_start(10);
    disk_box.set_margin_end(10);
    
    let sys_ref = sys.borrow();
    
    for disk in sys_ref.disks() {
        let total_gb = disk.total_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let available_gb = disk.available_space() as f64 / 1024.0 / 1024.0 / 1024.0;
        let used_gb = total_gb - available_gb;
        let used_percent = (used_gb / total_gb) * 100.0;
        
        let disk_label = Label::new(None);
        disk_label.set_markup(&format!(
            "<b>{}:</b> {:.1} GB / {:.1} GB ({:.1}% used)",
            disk.mount_point().display(),
            used_gb,
            total_gb,
            used_percent
        ));
        disk_label.set_xalign(0.0);
        
        disk_box.append(&disk_label);
    }
    
    disk_box
}

// ============================================
// TAB 3: DETAILS (Full Process List)
// ============================================

fn create_details_tab(sys: &Rc<RefCell<System>>) -> Box {
    let tab_box = Box::new(Orientation::Vertical, 5);
    tab_box.set_margin_top(10);
    tab_box.set_margin_bottom(10);
    tab_box.set_margin_start(10);
    tab_box.set_margin_end(10);

    let scroll = ScrolledWindow::builder()
        .hscrollbar_policy(gtk::PolicyType::Automatic)
        .vexpand(true)
        .build();
    
    let list_box = ListBox::new();
    let sys_ref = sys.borrow();
    
    // Header
    let header = Box::new(Orientation::Horizontal, 10);
    header.set_margin_start(5);
    
    let pid_label = Label::new(None);
    pid_label.set_markup("<b>PID</b>");
    pid_label.set_width_chars(8);
    pid_label.set_xalign(0.0);
    
    let name_label = Label::new(None);
    name_label.set_markup("<b>Name</b>");
    name_label.set_width_chars(35);
    name_label.set_xalign(0.0);
    
    let cpu_label = Label::new(None);
    cpu_label.set_markup("<b>CPU %</b>");
    cpu_label.set_width_chars(10);
    cpu_label.set_xalign(0.0);
    
    let mem_label = Label::new(None);
    mem_label.set_markup("<b>Memory (MB)</b>");
    mem_label.set_width_chars(15);
    mem_label.set_xalign(0.0);
    
    let status_label = Label::new(None);
    status_label.set_markup("<b>Status</b>");
    status_label.set_width_chars(12);
    status_label.set_xalign(0.0);
    
    header.append(&pid_label);
    header.append(&name_label);
    header.append(&cpu_label);
    header.append(&mem_label);
    header.append(&status_label);
    list_box.append(&header);
    
    // All processes sorted by CPU
    let mut processes: Vec<_> = sys_ref.processes().iter().collect();
    processes.sort_by(|a, b| {
        b.1.cpu_usage().partial_cmp(&a.1.cpu_usage()).unwrap()
    });
    
    for (pid, process) in processes.iter() {
        let row = Box::new(Orientation::Horizontal, 10);
        row.set_margin_start(5);
        
        let pid_label = Label::new(Some(&pid.to_string()));
        pid_label.set_width_chars(8);
        pid_label.set_xalign(0.0);
        
        let name_label = Label::new(Some(process.name()));
        name_label.set_width_chars(35);
        name_label.set_xalign(0.0);
        name_label.set_ellipsize(gtk::pango::EllipsizeMode::End);
        
        let cpu_label = Label::new(Some(&format!("{:.1}", process.cpu_usage())));
        cpu_label.set_width_chars(10);
        cpu_label.set_xalign(0.0);
        
        let mem_mb = process.memory() as f64 / 1024.0 / 1024.0;
        let mem_label = Label::new(Some(&format!("{:.1}", mem_mb)));
        mem_label.set_width_chars(15);
        mem_label.set_xalign(0.0);
        
        let status_label = Label::new(Some("Running"));
        status_label.set_width_chars(12);
        status_label.set_xalign(0.0);
        
        row.append(&pid_label);
        row.append(&name_label);
        row.append(&cpu_label);
        row.append(&mem_label);
        row.append(&status_label);
        list_box.append(&row);
    }
    
    scroll.set_child(Some(&list_box));
    tab_box.append(&scroll);

    tab_box
}


