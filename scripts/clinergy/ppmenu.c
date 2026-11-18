/*
 * ppmenu: a stand-in menu bar for the Clinergy / PEN&PAD demo under Wine.
 *
 * Under Wine the Pen&Pad frame window shows no menu bar (GetMenu returns NULL), so its
 * Model, DEM, Window and Host Prog commands cannot be reached with the mouse. ppmenu loads
 * the original menu (resource 129) from penpad.exe as a data file, puts it on a small
 * always-on-top window, and forwards each chosen command to the Pen&Pad frame as the
 * WM_COMMAND the real menu would have sent. Nothing in penpad.exe is changed.
 *
 *   ppmenu [path\to\penpad.exe]      (default: penpad.exe in the current folder)
 * Build: i686-w64-mingw32-gcc -O1 -mwindows -o ppmenu.exe ppmenu.c
 */
#include <windows.h>
#include <string.h>

static HWND gMain;

static BOOL CALLBACK find_main(HWND h, LPARAM lp) {
    char t[256] = "";
    DWORD pid = 0;
    GetWindowThreadProcessId(h, &pid);
    if (pid == GetCurrentProcessId()) return TRUE; /* skip our own window */
    GetWindowTextA(h, t, sizeof t);
    if (!gMain && IsWindowVisible(h) && !strncmp(t, "Pen&Pad", 7)) gMain = h;
    return TRUE;
}

static LRESULT CALLBACK wndproc(HWND h, UINT m, WPARAM w, LPARAM l) {
    if (m == WM_COMMAND && HIWORD(w) == 0) {
        gMain = NULL;
        EnumWindows(find_main, 0);
        if (gMain) {
            SetForegroundWindow(gMain);
            PostMessageA(gMain, WM_COMMAND, MAKEWPARAM(LOWORD(w), 0), 0);
        } else MessageBoxA(h, "Pen&Pad is not running.", "ppmenu", MB_OK);
        return 0;
    }
    if (m == WM_DESTROY) { PostQuitMessage(0); return 0; }
    return DefWindowProcA(h, m, w, l);
}

int WINAPI WinMain(HINSTANCE inst, HINSTANCE prev, LPSTR cmd, int show) {
    const char *exe = (cmd && *cmd) ? cmd : "penpad.exe";
    HMODULE res = LoadLibraryExA(exe, NULL, LOAD_LIBRARY_AS_DATAFILE);
    HMENU menu = res ? LoadMenuA(res, MAKEINTRESOURCEA(129)) : NULL;
    if (!menu) { MessageBoxA(NULL, "Could not load menu 129 from penpad.exe", "ppmenu", MB_OK); return 1; }
    WNDCLASSA wc = {0};
    wc.lpfnWndProc = wndproc; wc.hInstance = inst; wc.lpszClassName = "ppmenu";
    wc.hbrBackground = (HBRUSH)(COLOR_BTNFACE + 1); wc.hCursor = LoadCursor(NULL, IDC_ARROW);
    RegisterClassA(&wc);
    HWND h = CreateWindowExA(WS_EX_TOPMOST | WS_EX_TOOLWINDOW, "ppmenu", "Pen&Pad menu (ppmenu)",
                             WS_OVERLAPPED | WS_CAPTION | WS_SYSMENU, 0, GetSystemMetrics(SM_CYSCREEN) - 90, 640, 60, NULL, menu, inst, NULL);
    ShowWindow(h, SW_SHOWNOACTIVATE);
    MSG msg;
    while (GetMessageA(&msg, NULL, 0, 0) > 0) { TranslateMessage(&msg); DispatchMessageA(&msg); }
    return 0;
}
