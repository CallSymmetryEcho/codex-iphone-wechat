// Read the text inside one rectangle of the iPhone Mirroring window (on-device Vision OCR).
// Used to check WeChat's input box only: checking the whole screen passes on older bubbles that share the text.
// Build: swiftc -O tools/boxocr.swift -o tools/boxocr     Usage: tools/boxocr X Y W H   (window points, 355x782 window)
import AppKit
import Vision

func die(_ m: String) -> Never { FileHandle.standardError.write((m + "\n").data(using: .utf8)!); exit(1) }
let a = CommandLine.arguments.dropFirst().compactMap { Double($0) }
guard a.count == 4 else { die("usage: boxocr X Y W H") }
let list = CGWindowListCopyWindowInfo([.optionOnScreenOnly], kCGNullWindowID) as? [[String: Any]] ?? []
guard let w = list.first(where: { ($0[kCGWindowOwnerName as String] as? String) == "iPhone Mirroring" && ($0[kCGWindowLayer as String] as? Int) == 0 }),
      let b = w[kCGWindowBounds as String] as? [String: CGFloat],
      let windowID = w[kCGWindowNumber as String] as? Int,
      let width = b["Width"], let height = b["Height"] else { die("iPhone Mirroring window not found") }
let png = NSTemporaryDirectory() + "boxocr-" + UUID().uuidString + ".png"
defer { try? FileManager.default.removeItem(atPath: png) }
let p = Process(); p.executableURL = URL(fileURLWithPath: "/usr/sbin/screencapture"); p.arguments = ["-x", "-o", "-l\(windowID)", png]
try! p.run(); p.waitUntilExit()
guard p.terminationStatus == 0, let img = NSImage(contentsOfFile: png)?.cgImage(forProposedRect: nil, context: nil, hints: nil)
else { die("screen capture failed (Screen Recording permission for this terminal?)") }
let req = VNRecognizeTextRequest()
guard let region = img.cropping(to: CGRect(x: a[0] * Double(img.width) / width,
                                           y: a[1] * Double(img.height) / height,
                                           width: a[2] * Double(img.width) / width,
                                           height: a[3] * Double(img.height) / height)) else { die("invalid OCR region") }
req.recognitionLanguages = ["zh-Hans", "en-US"]
req.usesLanguageCorrection = false
try! VNImageRequestHandler(cgImage: region).perform([req])
print((req.results ?? []).compactMap { $0.topCandidates(1).first?.string }.joined(separator: "\n"))
