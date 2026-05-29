#include <flutter/dart_project.h>
#include <flutter/flutter_window.h>
#include <windows.h>

#include "utils.h"

int APIENTRY wWinMain(_In_ HINSTANCE instance, _In_opt_ HINSTANCE prev,
        _In_ wchar_t *command_line, _In_ int show_command) {
// Attach to console when present (e.g. 'flutter run') or create a
// new console when running the app standalone.
if (!AttachConsole(ATTACH_PARENT_PROCESS) && GetLastError() != ERROR_ACCESS_DENIED) {
CreateConsoleScreenBuffer(GENERIC_READ | GENERIC_WRITE,
FILE_SHARE_READ | FILE_SHARE_WRITE, nullptr,
CONSOLE_TEXTMODE_BUFFER, nullptr);
}
std::vector<std::string> command_line_arguments =
        GetCommandLineArguments();

std::string assets_path_string = GetAssetsPath();
std::wstring assets_path = std::wstring(assets_path_string.begin(),
        assets_path_string.end());

flutter::DartProject project(assets_path);
std::vector<std::string> dart_entrypoint_arguments;
for (const auto& arg : command_line_arguments) {
dart_entrypoint_arguments.push_back(arg);
}
project.set_dart_entrypoint_arguments(std::move(dart_entrypoint_arguments));

flutter::FlutterWindow window(project);
WindowProperties window_properties = GetWindowProperties();
window_properties.title = L"CRUX - Vidéoconférence Premium";
window.SetProperties(window_properties);

if (!window.OnCreate()) {
return EXIT_FAILURE;
}
window.Show();

::MSG msg;
while (::GetMessage(&msg, nullptr, 0, 0)) {
::TranslateMessage(&msg);
::DispatchMessage(&msg);
}

return EXIT_SUCCESS;
}