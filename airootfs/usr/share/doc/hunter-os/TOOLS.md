# Hunter OS Tools Reference

## Network Analysis

### nmap
**Purpose**: Network discovery and security auditing  
**Usage**: `nmap [options] <target>`  
**Examples**:
```bash
# Ping scan to discover hosts
nmap -sn 192.168.1.0/24

# Full TCP port scan
nmap -p- -sV 192.168.1.100

# OS detection
nmap -O 192.168.1.100
```

### wireshark
**Purpose**: Network protocol analyzer  
**Usage**: GUI application or `tshark` for CLI  
**Examples**:
```bash
# Capture on interface
sudo wireshark -i eth0

# CLI capture
sudo tshark -i eth0 -w capture.pcap
```

### tcpdump
**Purpose**: Packet capture and analysis  
**Usage**: `tcpdump [options]`  
**Examples**:
```bash
# Capture HTTP traffic
sudo tcpdump -i eth0 port 80

# Save to file
sudo tcpdump -i eth0 -w capture.pcap
```

---

## Web Application Security

### burpsuite
**Purpose**: Web application security testing  
**Usage**: GUI application  
**Launch**: Applications → Web Analysis → Burp Suite

### sqlmap
**Purpose**: SQL injection detection and exploitation  
**Usage**: `sqlmap [options]`  
**Examples**:
```bash
# Test URL for SQL injection
sqlmap -u "http://example.com/page?id=1"

# Dump database
sqlmap -u "http://example.com/page?id=1" --dbs
```

### nikto
**Purpose**: Web server scanner  
**Usage**: `nikto [options]`  
**Examples**:
```bash
# Scan web server
nikto -h http://example.com

# Scan with SSL
nikto -h https://example.com -ssl
```

---

## Exploitation

### metasploit
**Purpose**: Penetration testing framework  
**Usage**: `msfconsole`  
**Examples**:
```bash
# Start Metasploit
msfconsole

# Search for exploits
msf6 > search apache

# Use exploit
msf6 > use exploit/multi/handler
```

---

## Password Attacks

### john
**Purpose**: Password cracking  
**Usage**: `john [options] <password-file>`  
**Examples**:
```bash
# Crack password file
john passwords.txt

# Use wordlist
john --wordlist=/usr/share/wordlists/rockyou.txt hashes.txt
```

### hashcat
**Purpose**: Advanced password recovery  
**Usage**: `hashcat [options] <hash-file> <wordlist>`  
**Examples**:
```bash
# Crack MD5 hashes
hashcat -m 0 hashes.txt wordlist.txt

# Brute force
hashcat -m 0 -a 3 hashes.txt ?a?a?a?a?a?a
```

### hydra
**Purpose**: Network login cracker  
**Usage**: `hydra [options] <target>`  
**Examples**:
```bash
# SSH brute force
hydra -l admin -P passwords.txt ssh://192.168.1.100

# HTTP form
hydra -l admin -P passwords.txt 192.168.1.100 http-post-form "/login:user=^USER^&pass=^PASS^:F=incorrect"
```

---

## Wireless Attacks

### aircrack-ng
**Purpose**: WiFi security auditing  
**Usage**: Suite of tools  
**Examples**:
```bash
# Put interface in monitor mode
sudo airmon-ng start wlan0

# Capture packets
sudo airodump-ng wlan0mon

# Crack WPA
aircrack-ng -w wordlist.txt capture.cap
```

---

## Forensics

### autopsy
**Purpose**: Digital forensics platform  
**Usage**: GUI application  
**Launch**: Applications → Forensics → Autopsy

### volatility
**Purpose**: Memory forensics  
**Usage**: `volatility [options]`  
**Examples**:
```bash
# Identify image info
volatility -f memory.dump imageinfo

# List processes
volatility -f memory.dump --profile=Win7SP1x64 pslist
```

---

## Hunter OS Specific Tools

### hunter
**Purpose**: Main Hunter OS command  
**Usage**: `hunter [command]`  
**Commands**:
- `hunter --help` - Show help
- `hunter update` - Update tool database
- `hunter search <tool>` - Search for tools

### hunter-monitor
**Purpose**: System resource monitor  
**Usage**: `hunter-monitor` or click desktop icon  
**Features**:
- CPU/RAM/Disk usage
- Process list
- GPU information

### hunter-ai
**Purpose**: AI coding assistant  
**Usage**: `ollama run qwen2.5-coder:1.5b`  
**Features**:
- Code generation
- Debugging help
- Security advice

---

## Wordlists

Common wordlists location: `/usr/share/wordlists/`

- `rockyou.txt` - Popular password list
- `dirb/` - Directory brute forcing
- `wfuzz/` - Web fuzzing
- `metasploit/` - Metasploit wordlists

---

## Tips & Best Practices

1. **Always get permission** before testing systems
2. **Use VPN** for anonymity when appropriate
3. **Document everything** during penetration tests
4. **Update tools regularly** with `hunter update`
5. **Check tool documentation** with `man <tool>` or `<tool> --help`

---

For more information, see `/usr/share/doc/hunter-os/README.md`
