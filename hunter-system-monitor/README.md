# Hunter System Monitor

A lightweight, fast system monitor for Hunter OS written in Rust - similar to Windows Task Manager.

## Features

- 🔥 **CPU Usage** - Real-time CPU monitoring
- 💾 **RAM Usage** - Memory usage with total/used display
- 💿 **Swap Usage** - Swap space monitoring
- 📊 **Process List** - Top 20 processes by CPU usage
- 💽 **Disk Usage** - All mounted disks with space info
- ⚡ **Fast** - Written in Rust for minimal resource usage
- 🎨 **GTK4 GUI** - Modern, clean interface

## Screenshots

```
┌─────────────────────────────────────────────────────────┐
│  Hunter System Monitor                                  │
├─────────────────────────────────────────────────────────┤
│  🔥 CPU: 15.3%   💾 RAM: 1024 MB / 2048 MB (50.0%)     │
│  💿 Swap: 256 MB / 2048 MB                             │
├─────────────────────────────────────────────────────────┤
│  PID    Process Name           CPU %    Memory (MB)    │
│  1234   firefox                25.5     450.2          │
│  5678   onlyoffice             12.3     280.5          │
│  9012   hunter-monitor         2.1      15.8           │
│  ...                                                    │
├─────────────────────────────────────────────────────────┤
│  💽 Disk Usage                                          │
│  /: 45.2 GB / 100.0 GB (45.2% used)                    │
│  /home: 12.5 GB / 50.0 GB (25.0% used)                 │
└─────────────────────────────────────────────────────────┘
```

## Building

```bash
cd hunter-system-monitor
./build.sh
```

## Usage

Launch from:
- Applications menu → System → Hunter System Monitor
- Desktop icon
- Terminal: `hunter-monitor`

## Performance

- **Binary size:** ~2 MB (optimized)
- **RAM usage:** ~15 MB (vs 50+ MB for Python alternatives)
- **CPU usage:** <1% idle
- **Update interval:** 2 seconds

## Dependencies

- GTK4
- sysinfo (Rust crate)

## License

Part of Hunter OS
