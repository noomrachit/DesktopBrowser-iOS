# HANDOFF — Desktop Browser for iPhone

อัปเดตล่าสุด: 2026-09-27

## วิธีเริ่มงานสำหรับผู้ช่วยคนถัดไป

1. อ่าน `README.md` และไฟล์นี้ก่อน
2. ตรวจ `git status` และ `git log --oneline`
3. ทบทวนหัวข้อ "สถานะ" และ "งานค้าง" แล้วทำข้อถัดไป
4. ถ้าข้อมูลใน README, HANDOFF และโค้ดไม่ตรงกัน ให้แจ้งผู้ใช้ก่อนแก้
5. ให้เครื่องมือเดียวเป็นผู้แก้ไขหลักในแต่ละช่วง แล้วอัปเดตไฟล์นี้ทุกครั้งที่จบงาน

## สถานะ

- โปรเจกต์ SwiftUI + WKWebView, iOS 17+, ไฟล์ Swift 9 ไฟล์ (ประมาณ 530 บรรทัด)
- มี `project.pbxproj` ที่เขียนด้วยมือ และ `project.yml` สำหรับ XcodeGen
- มี GitHub Actions (`.github/workflows/ios-build.yml`) สำหรับ build บน simulator โดยไม่ต้อง sign
- ยังไม่เคยยืนยันว่า build ผ่าน เพราะสภาพแวดล้อมที่ตรวจเป็น Linux ไม่มี Xcode
- Git: ในไฟล์ zip ต้นฉบับไม่มี repository เริ่มสร้าง repository ใหม่พร้อม commit แรกแล้ว
- 2026-09-27: push โปรเจกต์ทั้งหมดขึ้น branch `claude/new-session-7o1zks` แล้ว GitHub Actions (`iOS Build Check`, macos-26, xcodebuild) **ผ่าน** — ยืนยันแล้วว่าโปรเจกต์คอมไพล์ได้จริงบน macOS/Xcode
- 2026-09-27: เพิ่มเปอร์เซ็นต์ดาวน์โหลดและ pause/resume แล้ว push ขึ้น GitHub และ CI **ผ่าน** (run 36331438890)
- 2026-09-27: เพิ่มเปิดหน้าต่างใหม่เป็นแท็บใหม่แล้ว push ขึ้น GitHub และ CI **ผ่าน** (run 36331591484)
- 2026-09-27: เพิ่มไอคอนแอปแล้ว (ดูหัวข้อ "งานค้าง" ข้อ 6) — ยังไม่ได้ยืนยันด้วย build จริงบน macOS หลังจากแก้ ทำให้ครบทุกข้อใน README/HANDOFF แล้ว

## โครงสร้าง

| ไฟล์ | หน้าที่ |
|---|---|
| `DesktopBrowserApp.swift` | จุดเริ่มแอป สร้าง `BrowserStore` และ `DownloadManager` |
| `ContentView.swift` | แถบแท็บ แถบนำทาง ช่อง URL แถบโหลด และหน้าเว็บ |
| `Models/BrowserTab.swift` | หนึ่งแท็บ = หนึ่ง `WKWebView` ตั้งค่าโหมด Desktop, ตัวกรอง scheme, ส่งต่อการดาวน์โหลด, เรียก `onOpenNewTab` เมื่อเว็บเปิดหน้าต่างใหม่ |
| `Models/DownloadRecord.swift` | ข้อมูลรายการดาวน์โหลด รวมจำนวนไบต์ที่โหลดแล้ว/ทั้งหมด และเปอร์เซ็นต์ที่คำนวณจากไบต์ |
| `Managers/BrowserStore.swift` | เพิ่ม เลือก ปิดแท็บ, ผูก `BrowserTab.onOpenNewTab` ให้เปิดแท็บใหม่ |
| `Managers/DownloadManager.swift` | จัดการ `WKDownload` บันทึกลง Documents/Downloads, ติดตามความคืบหน้าด้วย KVO บน `download.progress`, หยุดชั่วคราว/ต่อด้วย `cancel(resultHandler:)` + `resumeDownload(fromResumeData:)` |
| `Views/*` | ตัวห่อ WebView, แถบแท็บ, รายการดาวน์โหลด |
| `Assets.xcassets/AppIcon.appiconset` | ไอคอนแอป (รูปเดียว 1024×1024 แบบ single-size ของ Xcode 14+ ให้ระบบ scale เอง) |

## จุดที่ไม่ตรงกันระหว่าง README กับโค้ด (แก้แล้ว 2026-09-24 รอยืนยันด้วยการ build)

1. **UI ของแท็บอาจไม่อัปเดต** (แก้แล้ว: เพิ่ม `NavigationBarView` และ `TabChip` ที่ใช้ `@ObservedObject var tab`) — `ContentView` ติดตามแค่ `BrowserStore` แต่ค่า `isLoading`, `progress`, `canGoBack`, `canGoForward`, `title` อยู่ใน `BrowserTab` ซึ่งเป็น `ObservableObject` แยก การเปลี่ยนค่าของแท็บจึงไม่ทำให้ `ContentView` และ `TabStripView` วาดใหม่ ผลคือแถบความคืบหน้า ปุ่มย้อนกลับ/ไปข้างหน้า ปุ่มรีโหลด/หยุด ชื่อแท็บ และช่อง URL อาจค้าง ขัดกับฟีเจอร์ที่ README ระบุ
2. **ไฟล์ดาวน์โหลดไม่ปรากฏในแอป Files** (แก้แล้ว: เพิ่มคีย์ทั้งใน `project.pbxproj` และ `project.yml`) — ยังไม่มีคีย์ `UIFileSharingEnabled` และ `LSSupportsOpeningDocumentsInPlace` ผู้ใช้เปิดไฟล์ได้เฉพาะผ่าน Share Sheet ในแอป

## ความเสี่ยงที่ยังไม่ได้ยืนยัน

- เพิ่ม shared scheme `DesktopBrowser.xcscheme` แล้ว ยังไม่ได้ทดสอบกับ Xcode จริง
- โค้ดที่แก้ยังไม่ผ่านคอมไพเลอร์ ต้องรอผล build บน macOS
- `project.pbxproj` เขียนด้วยมือ อาจเปิดใน Xcode ไม่ได้ ทางสำรองคือสร้างใหม่ด้วย `xcodegen generate`
- CI ใช้ `runs-on: macos-26` ต้องตรวจว่า runner นี้มีให้ใช้จริง
- รายการดาวน์โหลดไม่ถูกบันทึกถาวร หายเมื่อปิดแอป
- Pause/resume ยังไม่ได้ทดสอบบน Xcode จริง (สภาพแวดล้อมนี้เป็น Linux ไม่มี Xcode) ควรตรวจ:
  - `WKDownload.progress` ยิง KVO ตามจริงกับเว็บไซต์ทดสอบหลายแบบ (ไฟล์ใหญ่/เล็ก, ไม่รู้ขนาดล่วงหน้า)
  - เซิร์ฟเวอร์ปลายทางต้องรองรับ HTTP range request ไม่งั้น `resumeData` จาก `download.cancel` อาจเป็น nil (โค้ดจัดการกรณีนี้แล้วโดยตั้งสถานะเป็น "ไม่สำเร็จ")
  - ถ้าปิดแท็บต้นทางระหว่างที่ดาวน์โหลดหยุดชั่วคราว `DownloadManager` จะยังถือ reference ของ `WKWebView` เดิมไว้จนกว่าจะ resume หรือ "ล้าง" รายการ (กันไม่ให้ resume ไม่ได้ แต่ทำให้ webview นั้น deallocate ช้าลง)

## งานค้าง (เรียงตามลำดับ)

1. [x] ผู้ใช้ยืนยันให้แก้ข้อ 1, ข้อ 2 และเพิ่ม scheme
2. [x] แก้ข้อ 1
3. [x] แก้ข้อ 2
4. [x] เพิ่ม shared scheme
5. [x] push ขึ้น GitHub แล้วดูผล GitHub Actions — ผ่าน (run 36331086129)
6. งานถัดไปจาก README:
   - [x] เปอร์เซ็นต์ดาวน์โหลด — เพิ่มแล้ว, CI ผ่าน
   - [x] pause/resume ดาวน์โหลด — เพิ่มแล้ว, CI ผ่าน แต่ยังไม่ทดสอบพฤติกรรมจริงบนอุปกรณ์/simulator (ดู "ความเสี่ยงที่ยังไม่ได้ยืนยัน")
   - [x] เปิดหน้าต่างใหม่เป็นแท็บใหม่ — เพิ่มแล้ว, CI ผ่าน
   - [x] ไอคอนแอป — เพิ่มแล้ว (ดูบันทึกการทำงาน) รอยืนยันด้วย CI/build

ทุกข้อใน "งานถัดไปจาก README" ทำครบแล้ว งานที่เหลือคือสิ่งที่ระบุใน "ข้อจำกัด" ของ README (เช่น App Store icon assets เพิ่มเติม, นโยบายความเป็นส่วนตัว, ทดสอบความปลอดภัย) ซึ่งเป็นงานเตรียมส่ง App Store ไม่ใช่ฟีเจอร์

## บันทึกการทำงาน

- 2026-09-24: ตรวจโค้ดทั้งหมด สร้าง HANDOFF.md และ Git repository ยังไม่แก้โค้ด
- 2026-09-24: แก้การอัปเดต UI ของแท็บ เปิดการแชร์ไฟล์กับแอป Files และเพิ่ม shared scheme (ยังไม่ได้ build)
- 2026-09-27: import โปรเจกต์จาก zip เข้า repo บน branch `claude/new-session-7o1zks`, push ขึ้น GitHub, ยืนยัน CI ผ่าน (macos-26, xcodebuild)
- 2026-09-27: เพิ่มเปอร์เซ็นต์ดาวน์โหลดและ pause/resume:
  - `DownloadRecord`: เพิ่ม `.paused` state, `totalBytesWritten`/`totalBytesExpectedToWrite`, computed `fractionCompleted`/`formattedProgress`
  - `DownloadManager`: สังเกตการณ์ `download.progress` ด้วย KVO (`completedUnitCount`), เพิ่ม `pause(_:)` ที่เรียก `download.cancel(resultHandler:)` เก็บ `resumeData`, เพิ่ม `resume(_:)` ที่เรียก `webView.resumeDownload(fromResumeData:)` บน `WKWebView` ต้นทางที่เก็บไว้จาก `download.webView`
  - `DownloadListView`: แสดงแถบความคืบหน้า + เปอร์เซ็นต์/ขนาดไฟล์ และปุ่มหยุดชั่วคราว/ต่อ ตามสถานะ
  - ยังไม่ได้ build บน Xcode จริง (สภาพแวดล้อมนี้ไม่มี Xcode) — ต้องตรวจผล CI หลัง push
- 2026-09-27: เพิ่มเปิดหน้าต่างใหม่เป็นแท็บใหม่:
  - `BrowserTab`: เพิ่ม `var onOpenNewTab: ((URL) -> Void)?`, เรียกใน `webView(_:createWebViewWith:for:windowFeatures:)` แทนการ `webView.load(...)` ในแท็บเดิม (ยังคงเช็ค `navigationAction.targetFrame == nil` เหมือนเดิม และ fallback เป็นโหลดในแท็บเดิมถ้าไม่มี callback)
  - `BrowserStore.addTab(...)`: ผูก `tab.onOpenNewTab` ให้เรียก `addTab` ตัวเองอีกครั้งด้วย URL ใหม่ (ใช้ `[weak self]` กัน retain cycle) ทำให้แท็บใหม่ถูกเพิ่มเข้า `tabs` และถูกเลือกเป็นแท็บปัจจุบันทันที
  - push ขึ้น GitHub และ CI **ผ่าน** (run 36331591484)
- 2026-09-27: เพิ่มไอคอนแอป:
  - สร้าง `DesktopBrowser/Assets.xcassets/AppIcon.appiconset/` ด้วยรูป PNG เดียวขนาด 1024×1024 (ไม่มี alpha channel ตามข้อกำหนดของ App Store) ใช้รูปแบบ single-size app icon ของ Xcode 14+ (`idiom: universal`) ให้ Xcode สร้างขนาดย่อยเองตอน build
  - รูปเป็นไอคอนจอคอมพิวเตอร์ (desktop monitor) พร้อมลูกโลกตรงกลางจอ สื่อถึง "เบราว์เซอร์โหมด Desktop" วาดด้วยสคริปต์ Python + Pillow ไม่ได้ใช้ asset ภายนอก
  - เพิ่ม `ASSETCATALOG_COMPILER_APPICON_NAME = AppIcon` ใน `project.pbxproj` (ทั้ง Debug/Release) และ `project.yml`
  - เพิ่ม `Assets.xcassets` เป็น PBXFileReference/PBXBuildFile ใน `project.pbxproj` (แก้ด้วยมือ ตามรูปแบบเดิมของไฟล์ ยังไม่ได้เปิดใน Xcode จริง)
  - ยังไม่ได้ build บน Xcode จริง — ต้องตรวจผล CI หลัง push
