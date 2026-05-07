#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <unistd.h>
#include <sys/sysinfo.h>
#include <msgpack.h>
#include <time.h>

void get_cpu_usage(double *usage) {
    static unsigned long long prev_idle = 0, prev_total = 0;
    FILE *fp = fopen("/proc/stat", "r");
    
    if (fp == NULL) {
        *usage = 0.0;
        return;
    }
    
    char buffer[256];
    fgets(buffer, sizeof(buffer), fp);
    fclose(fp);
    
    unsigned long long user, nice, system, idle, iowait, irq, softirq, steal;
    sscanf(buffer, "cpu %llu %llu %llu %llu %llu %llu %llu %llu",
           &user, &nice, &system, &idle, &iowait, &irq, &softirq, &steal);
    
    unsigned long long total = user + nice + system + idle + iowait + irq + softirq + steal;
    unsigned long long total_idle = idle + iowait;
    
    if (prev_total != 0) {
        unsigned long long total_diff = total - prev_total;
        unsigned long long idle_diff = total_idle - prev_idle;
        
        if (total_diff > 0) {
            *usage = (double)(total_diff - idle_diff) / total_diff;
        } else {
            *usage = 0.0;
        }
    } else {
        *usage = 0.0;
    }
    
    prev_idle = total_idle;
    prev_total = total;
}

void send_metrics() {
    struct sysinfo info;
    sysinfo(&info);
    
    double cpu_usage;
    get_cpu_usage(&cpu_usage);
    
    // Get current timestamp
    time_t now = time(NULL);
    char timestamp[64];
    strftime(timestamp, sizeof(timestamp), "%Y-%m-%d %H:%M:%S", localtime(&now));
    
    // Print human-readable output to stderr
    fprintf(stderr, "[%s] CPU: %.2f%% | Memory: %lu MB / %lu MB | Uptime: %ld seconds\n",
            timestamp,
            cpu_usage * 100,
            (info.totalram - info.freeram) / (1024 * 1024),
            info.totalram / (1024 * 1024),
            info.uptime);
    
    // Create MessagePack data
    msgpack_sbuffer sbuf;
    msgpack_packer pk;
    msgpack_sbuffer_init(&sbuf);
    msgpack_packer_init(&pk, &sbuf, msgpack_sbuffer_write);
    
    // Pack map with 4 fields
    msgpack_pack_map(&pk, 4);
    
    // CPU usage
    msgpack_pack_str(&pk, 3);
    msgpack_pack_str_body(&pk, "cpu", 3);
    msgpack_pack_double(&pk, cpu_usage);
    
    // Memory used
    msgpack_pack_str(&pk, 3);
    msgpack_pack_str_body(&pk, "mem", 3);
    msgpack_pack_uint64(&pk, info.totalram - info.freeram);
    
    // Uptime
    msgpack_pack_str(&pk, 6);
    msgpack_pack_str_body(&pk, "uptime", 6);
    msgpack_pack_uint64(&pk, info.uptime);
    
    // Timestamp
    msgpack_pack_str(&pk, 9);
    msgpack_pack_str_body(&pk, "timestamp", 9);
    msgpack_pack_uint64(&pk, (uint64_t)now);
    
    // Write binary data to stdout
    fwrite(sbuf.data, 1, sbuf.size, stdout);
    fflush(stdout);
    
    msgpack_sbuffer_destroy(&sbuf);
}

int main() {
    fprintf(stderr, "Starting system metrics monitor...\n");
    fprintf(stderr, "Binary MessagePack data will be written to stdout\n");
    fprintf(stderr, "Human-readable logs below:\n\n");
    
    while (1) {
        send_metrics();
        sleep(1);
    }
    
    return 0;
}
