#include "flutter_window.h"

#include <optional>

#include "flutter/generated_plugin_registrant.h"

flutter::FlutterWindow::FlutterWindow(const flutter::DartProject& project)
        : project_(std::make_unique<flutter::DartProject>(project)),
          engine_(nullptr) {}

flutter::FlutterWindow::~FlutterWindow() {}

bool flutter::FlutterWindow::OnCreate() {
    if (!Win32Window::OnCreate()) {
        return false;
    }

    RECT client_area = GetClientArea();

    flutter::FlutterDesktopViewProperties properties = {};
    properties.view = GetHandle();
    properties.width = client_area.right - client_area.left;
    properties.height = client_area.bottom - client_area.top;
    properties.assets_path = project_->assets_path();

    properties.dart_entrypoint_arguments = project_->dart_entrypoint_arguments();

    engine_ = flutter::FlutterDesktopEngineCreate(&properties);
    if (!engine_) {
        return false;
    }

    if (!flutter::FlutterDesktopEngineStart(engine_)) {
        return false;
    }

    flutter::FlutterDesktopPluginRegistrarRef registrar =
            flutter::FlutterDesktopEngineGetPluginRegistrar(engine_, "");

    // The plugin registry should be called before calling FlutterWindowsInit.
    GeneratedPluginRegistrant::RegisterWithRegistrar(registrar);

    return true;
}

void flutter::FlutterWindow::OnDestroy() {
    if (engine_) {
        flutter::FlutterDesktopEngineDestroy(engine_);
        engine_ = nullptr;
    }

    Win32Window::OnDestroy();
}

LRESULT
flutter::FlutterWindow::MessageHandler(HWND hwnd, UINT const message,
        WPARAM const wparam,
        LPARAM const lparam) noexcept {
// Give Flutter, including plugins, a chance to handle window messages.
if (engine_ != nullptr) {
std::optional<LRESULT> result =
        flutter::FlutterDesktopEngineProcessMessage(engine_, hwnd, message,
                wparam, lparam);
if (result) {
return *result;
}
}

if (message == WM_FONTCHANGE) {
flutter::FlutterDesktopEngineReloadSystemFonts(engine_);
return 0;
}

return Win32Window::MessageHandler(hwnd, message, wparam, lparam);
}