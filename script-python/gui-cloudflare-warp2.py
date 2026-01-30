import sys
import subprocess
from PyQt5.QtWidgets import QApplication, QWidget, QPushButton, QLabel, QVBoxLayout

def run_cmd(cmd):
    try:
        subprocess.run(cmd, check=True)
    except subprocess.CalledProcessError as e:
        print(f"Error: {e}")

def get_status():
    result = subprocess.run(["warp-cli", "status"], capture_output=True, text=True)
    return "Connected" if "Connected" in result.stdout else "Disconnected"

class VPNWindow(QWidget):
    def __init__(self):
        super().__init__()
        self.setWindowTitle("VPN Toggle")
        self.layout = QVBoxLayout()

        self.status_label = QLabel(f"VPN Status: {get_status()}")
        self.layout.addWidget(self.status_label)

        self.toggle_button = QPushButton("Toggle VPN")
        self.toggle_button.clicked.connect(self.toggle_vpn)
        self.layout.addWidget(self.toggle_button)

        self.quit_button = QPushButton("Quit")
        self.quit_button.clicked.connect(self.close)
        self.layout.addWidget(self.quit_button)

        self.setLayout(self.layout)

    def toggle_vpn(self):
        status = get_status()
        if status == "Connected":
            run_cmd(["warp-cli", "disconnect"])
            self.status_label.setText("VPN Status: Disconnected")
        else:
            run_cmd(["warp-cli", "connect"])
            self.status_label.setText("VPN Status: Connected")

if __name__ == "__main__":
    app = QApplication(sys.argv)
    window = VPNWindow()
    window.show()
    sys.exit(app.exec_())

