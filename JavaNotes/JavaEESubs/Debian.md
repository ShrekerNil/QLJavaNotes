# Deepin

## 增强模式

是的，在 Hyper-V 上安装的 Deepin 20.9 可以实现与 Windows 宿主机共享剪贴板（以及文件拖放），但这**不是 Hyper-V 的默认功能**，需要手动配置启用 **Hyper-V 增强会话模式**。

以下是详细的操作步骤和说明：

📌 **核心原理：**
Hyper-V 的增强会话模式依赖于 Linux 虚拟机内安装并运行 `xrdp` 服务以及特定的 Hyper-V 集成服务组件（`hv_kvp_daemon` 等）。增强会话模式提供了比标准连接更丰富的功能，包括剪贴板共享、驱动器重定向（文件共享）、动态分辨率调整等。

### 📍 必要条件
1.  **Hyper-V 设置：** 确保宿主机的 Hyper-V 服务正常运行。
2.  **Deepin 虚拟机：** Deepin 20.9 虚拟机已安装并启动。建议使用 `linux-image-virtual` 内核（通常包含更完整的 Hyper-V 驱动支持），但标准内核通常也可工作。
3.  **网络连接：** 虚拟机需要能访问网络以下载安装包。

### 📍 配置步骤（在 Deepin 虚拟机内操作）
1.  **安装必要软件包：**
    *   打开 **终端**。
    *   更新软件包列表：
        ```bash
        sudo apt update
        ```
    *   安装 `xrdp` 和 `xfce4` 相关的包（xrdp 需要这些包来提供桌面环境会话）：
        ```bash
        sudo apt install -y xrdp xorgxrdp xfce4 xfce4-goodies
        ```
    *   安装 **Hyper-V 集成服务 (Linux Integration Services - LIS) / Hyper-V 工具**。这些通常包含在 `hyperv-daemons` 或 `linux-tools-virtual` 包中，但 Deepin 可能直接提供了 `hv-kvp-daemon` 等关键组件。安装以下包通常能满足要求：
        ```bash
        sudo apt install -y hyperv-daemons
        ```
        *   如果找不到 `hyperv-daemons`，尝试安装：
            ```bash
            sudo apt install -y linux-tools-virtual linux-cloud-tools-virtual
            ```

2.  **配置 xrdp 使用 Xfce4 会话：**
    *   创建或编辑 `.xsession` 文件（对当前用户生效）或 `/etc/xrdp/startwm.sh`（对所有用户生效）。推荐修改 `/etc/xrdp/startwm.sh`：
        ```bash
        sudo nano /etc/xrdp/startwm.sh
        ```
    *   在文件的 **末尾**、`fi` 语句之后（通常在最后几行），**添加**以下行：
        ```bash
        # 在文件末尾添加
        startxfce4
        ```
    *   保存并退出编辑器 (在 nano 中按 `Ctrl+O`, 回车, 然后 `Ctrl+X`)。

3.  **确保关键 Hyper-V 服务启动并启用：**
    *   检查并启动 `hv_kvp_daemon`（用于键值对交换，包括剪贴板）：
        ```bash
        sudo systemctl enable hv_kvp_daemon.service --now
        sudo systemctl status hv_kvp_daemon.service  # 确认状态为 active (running)
        ```
    *   启动并启用 `xrdp` 服务：
        ```bash
        sudo systemctl enable xrdp.service --now
        sudo systemctl status xrdp.service          # 确认状态为 active (running)
        ```
    *   （可选但推荐）启动并启用 `hv_fcopy_daemon`（用于文件复制）和 `hv_vss_daemon`（用于卷影复制）：
        ```bash
        sudo systemctl enable hv_fcopy_daemon.service --now
        sudo systemctl enable hv_vss_daemon.service --now
        ```

4.  **重启虚拟机（重要）：**
    ```bash
    sudo reboot
    ```

### 📍 从 Windows 宿主机连接（使用增强会话）
1.  关闭你当前可能正在使用的 Deepin 虚拟机窗口（如果开着的话）。
2.  打开 **Hyper-V 管理器**。
3.  右键点击你的 Deepin 20.9 虚拟机。
4.  选择 **连接...**。
5.  在打开的虚拟机连接窗口中，**不要**点击蓝色的“启动”按钮。
6.  点击窗口顶部的 **"查看"** 菜单。
7.  在下拉菜单中，选择 **"增强会话"**。
8.  **现在**点击蓝色的 **"启动"** 按钮。
9.  系统会提示你登录。关键区别在于：
    *   **"登录为:"** 下拉菜单会出现，选择 **"Xorg"** (这是关键一步！)。
    *   输入你的 Deepin 用户名和密码。
    *   点击 **"确定"** 或 **"登录"**。

### 📍 验证剪贴板共享
1.  在 Deepin 虚拟机中，复制一段文本（例如在文本编辑器中）。
2.  切换到 Windows 宿主机上的任意程序（如记事本），尝试粘贴 (Ctrl+V)。应该能看到 Deepin 中复制的文本。
3.  在 Windows 宿主机上复制一段文本。
4.  切换回 Deepin 虚拟机中的程序（如文本编辑器），尝试粘贴 (Ctrl+V)。应该能看到 Windows 中复制的文本。

### ⚠ 注意事项
*   **登录方式选择：** 启动增强会话时，**必须**在登录界面的 **"登录为："** 下拉菜单中选择 **"Xorg"**。选择 "Xvnc" 或其他选项通常无法启用剪贴板共享功能。
*   **Wayland 兼容性：** Deepin 默认可能使用 Wayland 显示服务器。增强会话模式下的剪贴板共享主要针对 **Xorg (X11)** 会话有效。如果你在 Deepin 中强制使用 Wayland，剪贴板共享很可能无法工作。在登录管理器界面（增强会话登录前）选择 Xorg 会话通常能解决。
*   **文件拖放：** 增强会话模式理论上也支持文件拖放（从宿主机拖到虚拟机窗口内）。如果安装了 `hv_fcopy_daemon` 并运行，这个功能通常也能用。尝试拖动一个文件到 Deepin 的桌面或文件管理器窗口。
*   **防火墙：** 确保 Deepin 虚拟机内的防火墙（如果有启用，如 `ufw`）允许 `xrdp` 的默认端口 `3389/tcp` 的入站连接。通常安装 `xrdp` 时会自动处理，但检查一下更安全：
    ```bash
    sudo ufw allow 3389/tcp
    ```
*   **内核更新：** 如果更新了 Deepin 的内核，有时可能需要重新安装或重新配置 `hyperv-daemons` / `linux-tools-virtual` 包。
*   **备选方案：** 如果增强会话设置遇到困难，可以考虑：
    *   **第三方工具：** 使用 `KDE Connect`（Deepin 应用商店可能有）在局域网内同步剪贴板和文件（需在 Windows 也安装 KDE Connect）。
    *   **共享文件夹：** 在 Hyper-V 管理器中设置 SMB 共享文件夹（"增强会话模式" -> "本地资源" -> "更多..."），在 Deepin 里挂载这个共享文件夹，通过文件共享间接传递文本内容（保存为文件）。

### 📎 总结
通过安装配置 `xrdp`、`xfce4` 相关包、Hyper-V 集成服务组件（特别是 `hv_kvp_daemon`），并在连接虚拟机时**明确选择使用 "增强会话" 模式登录为 "Xorg"**，即可实现 Hyper-V 上 Deepin 20.9 虚拟机与 Windows 宿主机之间的剪贴板双向共享功能。文件拖放功能通常也会一并启用。💻 如果遇到问题，请重点检查登录时的 "Xorg" 选择、相关服务状态和防火墙设置。