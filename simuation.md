# Debugging Remote GUI and MuJoCo/X11 Issues

This document collects tips and solutions for running GUI-based Python applications (e.g., Gymnasium/MuJoCo environments) on a remote server, including X11 forwarding, Xvfb, OpenGL, and Conda environment issues.

---

## 1. Running GUI Apps Remotely: X11 Forwarding

### **Requirements**
- An X server running on your local machine:
  - **Linux:** Already running by default.
  - **Mac:** Install and launch [XQuartz](https://www.xquartz.org/).
  - **Windows:** Install and launch [VcXsrv](https://sourceforge.net/projects/vcxsrv/) or [Xming](https://sourceforge.net/projects/xming/).

### **SSH with X11 Forwarding**
- Use `-X` (or `-Y` for trusted forwarding):
  ```bash
  ssh -Y -i ~/.ssh/id_ed25519 -p 20435 root@157.157.221.29
  # or
  ssh -X -i ~/.ssh/id_ed25519 -p 20435 root@157.157.221.29
  ```
- After connecting, check:
  ```bash
  echo $DISPLAY
  # Should output something like: localhost:10.0
  ```
- Test with a simple X11 app (install if needed):
  ```bash
  sudo apt-get install x11-apps
  xeyes
  # or
  xclock
  ```
- The window should appear on your local desktop (not in a browser).

### **On Mac (XQuartz):**
- Start XQuartz from terminal:
  ```bash
  open -a XQuartz
  ```
- If needed, allow network clients:
  - In XQuartz Preferences > Security, check "Allow connections from network clients".
- In your Mac terminal:
  ```bash
  xhost +
  ```
- SSH as above and test with `xeyes` or `xclock`.

---

## 2. Using Xvfb for Headless Rendering

- Install Xvfb:
  ```bash
  sudo apt-get install xvfb
  ```
- Run your script with Xvfb:
  ```bash
  xvfb-run -s "-screen 0 1400x900x24" python my_script.py
  ```
- **Note:** You will NOT see the GUI locally; this is for headless automation.

---

## 3. MuJoCo/OpenGL/GLX/EGL Issues

### **Common Errors and Fixes**

#### **Missing swrast_dri.so**
- Error:
  ```
  libGL error: failed to load driver: swrast
  .../swrast_dri.so: cannot open shared object file: No such file or directory
  ```
- Fix:
  ```bash
  sudo apt-get install -y libgl1-mesa-glx libgl1-mesa-dri mesa-utils
  ```

#### **GLIBCXX Version Not Found**
- Error:
  ```
  libstdc++.so.6: version `GLIBCXX_3.4.30' not found
  ```
- Fix (in Conda env):
  ```bash
  conda install -c conda-forge 'libstdcxx-ng>=12'
  # Verify:
  strings $CONDA_PREFIX/lib/libstdc++.so.6 | grep GLIBCXX
  ```

#### **libGLU.so.0 Missing**
- Error:
  ```
  Failed to load library ( 'libGLU.so.0' )
  ```
- Fix:
  ```bash
  sudo apt-get install -y libglu1-mesa
  ```

#### **EGL/GLX Context Errors**
- Try setting:
  ```bash
  export MUJOCO_GL=egl
  # or as a one-liner
  MUJOCO_GL=egl python my_script.py
  ```
- If using Xvfb, also set:
  ```bash
  export LIBGL_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri
  # or as a one-liner
  LIBGL_DRIVERS_PATH=/usr/lib/x86_64-linux-gnu/dri MUJOCO_GL=egl xvfb-run ...
  ```

---

## 4. Speech Synthesis Errors

- Error:
  ```
  FileNotFoundError: No such file or directory: 'spd-say'
  ```
- Fix:
  ```bash
  sudo apt-get install -y speech-dispatcher
  ```

---

## 5. File/Directory Exists Errors

- Error:
  ```
  FileExistsError: [Errno 17] File exists: '/root/.cache/huggingface/lerobot/pepijn223/il_gym0'
  ```
- Fix:
  - Delete the directory:
    ```bash
    rm -rf /root/.cache/huggingface/lerobot/pepijn223/il_gym0
    ```
  - Or, modify the code to use `exist_ok=True` in `mkdir`.

---

## 6. Viewing the GUI

- **Xvfb:** GUI is not visible; use for headless runs.
- **X11 Forwarding:** GUI appears on your local desktop if X11 forwarding is set up.
- **VNC:** For complex GUIs, set up a VNC server on the remote and connect with a VNC client.
- **Screenshots:** Use `xwd` or `ffmpeg` to capture the virtual display if needed.

---

## 7. Troubleshooting Checklist

- Is your local X server running? (XQuartz, VcXsrv, etc.)
- Did you SSH with `-X` or `-Y`?
- Is `$DISPLAY` set on the remote?
- Can you run `xeyes` or `xclock` and see the window locally?
- Are all required libraries installed (Mesa, GLU, speech-dispatcher, etc.)?
- For Conda: is `libstdcxx-ng` up to date?

---

## 8. Useful Commands

```bash
# Start XQuartz on Mac
open -a XQuartz

# Allow all hosts to connect to XQuartz
xhost +

# SSH with X11 forwarding
ssh -Y -i ~/.ssh/id_ed25519 -p 20435 root@157.157.221.29

# Install X11 test apps
sudo apt-get install x11-apps

# Test X11 forwarding
xeyes
xclock
```

---

## 9. Best Practice: Fully Interactive Gym/MuJoCo GUI from macOS (Remote NVIDIA GPU)

If you want to view and interact with a Gym/MuJoCo GUI (including keyboard/mouse input) from your Mac, and your remote server has an NVIDIA GPU, the most reliable method is to use a remote desktop (VNC) session. This leverages the GPU for hardware-accelerated OpenGL rendering and provides a full desktop environment for interaction.

### Step-by-Step: Remote VNC Desktop with NVIDIA GPU

1. **Install NVIDIA Drivers (if not already)**
   ```bash
   nvidia-smi
   ```
   - If you see your GPU, drivers are installed.
   - If not, install the latest NVIDIA drivers for your Linux distribution.

2. **Install a Desktop Environment and VNC Server**
   ```bash
   sudo apt-get update
   sudo apt-get install -y xfce4 xfce4-goodies tigervnc-standalone-server
   ```

3. **Set Up VNC Password**
   ```bash
   vncpasswd
   ```
   - Set a password for your VNC session.

4. **Start a VNC Session**
   ```bash
   vncserver :1
   ```
   - This starts a VNC desktop on display `:1` (port 5901).

5. **(Optional) Configure VNC to Use XFCE**
   If you don't see XFCE, edit `~/.vnc/xstartup` to contain:
   ```sh
   #!/bin/sh
   xrdb $HOME/.Xresources
   startxfce4 &
   ```
   Then make it executable:
   ```bash
   chmod +x ~/.vnc/xstartup
   ```
   Restart the VNC server:
   ```bash
   vncserver -kill :1
   vncserver :1
   ```

6. **Connect from Your Mac**
   - Download and install a VNC client (e.g., [TigerVNC Viewer](https://tigervnc.org/) or [RealVNC Viewer](https://www.realvnc.com/en/connect/download/viewer/)).
   - Connect to:
     ```
     <remote-server-ip>:5901
     ```
   - Enter your VNC password.

7. **Run Your Gym/MuJoCo Script in the VNC Desktop**
   - Open a terminal in the VNC desktop.
   - Run:
     ```bash
     python -m lerobot.scripts.rl.gym_manipulator --config_path ../env_config_gym_hil_il.json
     ```
   - The GUI window will appear in the VNC desktop, and you can interact with it using your Mac's keyboard and mouse.

### Why Not SSH X11 Forwarding?
- OpenGL/GLX over SSH X11 forwarding is unreliable and slow, even with a GPU.
- VNC gives you a full remote desktop with hardware acceleration and proper input handling.

### Summary Table

| Method         | GUI Quality | Keyboard/Mouse | Performance | Setup Difficulty |
|----------------|-------------|----------------|-------------|------------------|
| VNC + GPU      | Excellent   | Yes            | High        | Medium           |
| SSH X11        | Poor/Unreliable | Sometimes   | Low         | Easy             |
| EGL/Xvfb       | No GUI      | No             | High        | Easy             |

### Optional: Secure Your VNC Connection
- For extra security, tunnel VNC over SSH:
  ```bash
  ssh -L 5901:localhost:5901 -i ~/.ssh/id_ed25519 -p 20435 root@157.157.221.29
  ```
  Then connect your VNC client to `localhost:5901`.

---

**If you encounter a new error, search this file for the error message and try the suggested fix!** 