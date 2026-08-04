#!/usr/bin/env swift
import AppKit
import Foundation

private enum Palette {
  static let ink = NSColor(hex: 0x050505)
  static let blue = NSColor(hex: 0x0A84FF)
  static let paper = NSColor(hex: 0xFAF9F6)
  static let white = NSColor.white
  static let line = NSColor(hex: 0xC7C7CC)
  static let muted = NSColor(hex: 0x5F6368)
  static let chip = NSColor(hex: 0xE6F2FF)
}

private let fileManager = FileManager.default
private let repositoryRoot = URL(fileURLWithPath: fileManager.currentDirectoryPath)
private let sourceLogoURL = repositoryRoot.appending(
  path: "docs/images/brand-source/logo_ogamlabs_horizontal_full-color_light_1600x500.png"
)

guard let sourceLogo = NSImage(contentsOf: sourceLogoURL) else {
  fatalError("Missing first-party OgamLabs source logo at \(sourceLogoURL.path)")
}

func makeBitmap(
  width: Int,
  height: Int,
  draw: (NSGraphicsContext) -> Void
) -> NSBitmapImageRep {
  guard
    let bitmap = NSBitmapImageRep(
      bitmapDataPlanes: nil,
      pixelsWide: width,
      pixelsHigh: height,
      bitsPerSample: 8,
      samplesPerPixel: 4,
      hasAlpha: true,
      isPlanar: false,
      colorSpaceName: .deviceRGB,
      bitmapFormat: [],
      bytesPerRow: 0,
      bitsPerPixel: 0
    ), let context = NSGraphicsContext(bitmapImageRep: bitmap)
  else {
    fatalError("Unable to allocate bitmap")
  }

  NSGraphicsContext.saveGraphicsState()
  NSGraphicsContext.current = context
  context.shouldAntialias = true
  draw(context)
  context.flushGraphics()
  NSGraphicsContext.restoreGraphicsState()
  return bitmap
}

func writePNG(_ bitmap: NSBitmapImageRep, to url: URL) throws {
  guard let data = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Unable to encode PNG")
  }
  try data.write(to: url, options: .atomic)
}

func drawText(
  _ text: String,
  in rect: NSRect,
  font: NSFont,
  color: NSColor,
  alignment: NSTextAlignment = .left
) {
  let paragraph = NSMutableParagraphStyle()
  paragraph.alignment = alignment
  paragraph.lineBreakMode = .byWordWrapping
  (text as NSString).draw(
    in: rect,
    withAttributes: [
      .font: font,
      .foregroundColor: color,
      .paragraphStyle: paragraph,
    ]
  )
}

func drawRoundedRect(
  _ rect: NSRect,
  radius: Double,
  fill: NSColor,
  stroke: NSColor? = nil,
  lineWidth: Double = 1
) {
  let path = NSBezierPath(roundedRect: rect, xRadius: radius, yRadius: radius)
  fill.setFill()
  path.fill()
  if let stroke {
    stroke.setStroke()
    path.lineWidth = lineWidth
    path.stroke()
  }
}

func drawArrow(from start: NSPoint, to end: NSPoint) {
  Palette.line.setStroke()
  let path = NSBezierPath()
  path.lineWidth = 2
  path.move(to: start)
  path.line(to: end)
  path.stroke()

  let angle = atan2(end.y - start.y, end.x - start.x)
  let length = 10.0
  for offset in [Double.pi * 0.78, -Double.pi * 0.78] {
    let tip = NSPoint(
      x: end.x + cos(angle + offset) * length,
      y: end.y + sin(angle + offset) * length
    )
    let head = NSBezierPath()
    head.lineWidth = 2
    head.move(to: end)
    head.line(to: tip)
    head.stroke()
  }
}

func drawNode(_ title: String, rect: NSRect, emphasized: Bool = false) {
  drawRoundedRect(
    rect,
    radius: 16,
    fill: emphasized ? Palette.blue : Palette.paper,
    stroke: emphasized ? Palette.blue : Palette.line,
    lineWidth: 1.5
  )
  drawText(
    title,
    in: rect.insetBy(dx: 12, dy: 18),
    font: .systemFont(ofSize: 20, weight: .semibold),
    color: emphasized ? Palette.white : Palette.ink,
    alignment: .center
  )
}

let socialPreview = makeBitmap(width: 1280, height: 640) { _ in
  Palette.paper.setFill()
  NSBezierPath(rect: NSRect(x: 0, y: 0, width: 1280, height: 640)).fill()

  sourceLogo.draw(
    in: NSRect(x: 64, y: 525, width: 218, height: 68),
    from: .zero,
    operation: .sourceOver,
    fraction: 1
  )

  drawText(
    "iOS Architecture\nReference",
    in: NSRect(x: 64, y: 340, width: 650, height: 165),
    font: .systemFont(ofSize: 62, weight: .bold),
    color: Palette.ink
  )
  drawText(
    "A buildable Swift 6 vertical slice with boundaries\nthat stay visible in code, tests and delivery.",
    in: NSRect(x: 68, y: 260, width: 620, height: 72),
    font: .systemFont(ofSize: 24, weight: .regular),
    color: Palette.muted
  )

  let chips = ["SWIFT 6", "4 MODULES", "15 TESTS", "0 DEPENDENCIES"]
  var chipX = 64.0
  for chip in chips {
    let width = Double(chip.count * 10 + 32)
    let rect = NSRect(x: chipX, y: 183, width: width, height: 40)
    drawRoundedRect(rect, radius: 20, fill: Palette.chip)
    drawText(
      chip,
      in: rect.insetBy(dx: 10, dy: 12),
      font: .monospacedSystemFont(ofSize: 13, weight: .semibold),
      color: Palette.blue,
      alignment: .center
    )
    chipX += width + 10
  }

  drawText(
    "CLEAN ARCHITECTURE  ·  MVVM  ·  TYPED ROUTER",
    in: NSRect(x: 68, y: 105, width: 620, height: 28),
    font: .monospacedSystemFont(ofSize: 15, weight: .medium),
    color: Palette.ink
  )

  let card = NSRect(x: 748, y: 64, width: 468, height: 512)
  drawRoundedRect(card, radius: 28, fill: Palette.white, stroke: Palette.line)
  drawText(
    "DEPENDENCIES POINT INWARD",
    in: NSRect(x: 786, y: 515, width: 392, height: 28),
    font: .monospacedSystemFont(ofSize: 14, weight: .semibold),
    color: Palette.muted,
    alignment: .center
  )

  let composition = NSRect(x: 845, y: 423, width: 274, height: 62)
  let feature = NSRect(x: 785, y: 282, width: 176, height: 68)
  let data = NSRect(x: 1003, y: 282, width: 176, height: 68)
  let domain = NSRect(x: 865, y: 117, width: 234, height: 78)

  drawArrow(from: NSPoint(x: 920, y: 423), to: NSPoint(x: 873, y: 350))
  drawArrow(from: NSPoint(x: 1044, y: 423), to: NSPoint(x: 1091, y: 350))
  drawArrow(from: NSPoint(x: 873, y: 282), to: NSPoint(x: 932, y: 195))
  drawArrow(from: NSPoint(x: 1091, y: 282), to: NSPoint(x: 1032, y: 195))

  drawNode("Composition", rect: composition)
  drawNode("Feature", rect: feature)
  drawNode("Data", rect: data)
  drawNode("Domain", rect: domain, emphasized: true)
}

let signature = makeBitmap(width: 512, height: 160) { _ in
  NSColor.clear.setFill()
  NSBezierPath(rect: NSRect(x: 0, y: 0, width: 512, height: 160)).fill()
  drawRoundedRect(
    NSRect(x: 0, y: 0, width: 512, height: 160),
    radius: 18,
    fill: Palette.white
  )
  sourceLogo.draw(
    in: NSRect(x: 30, y: 10, width: 452, height: 141),
    from: .zero,
    operation: .sourceOver,
    fraction: 1
  )
}

try writePNG(socialPreview, to: repositoryRoot.appending(path: "docs/images/social-preview.png"))
try writePNG(signature, to: repositoryRoot.appending(path: "docs/images/ogamlabs-signature.png"))
print("Rendered repository brand assets.")

extension NSColor {
  fileprivate convenience init(hex: UInt32) {
    self.init(
      red: CGFloat((hex >> 16) & 0xFF) / 255,
      green: CGFloat((hex >> 8) & 0xFF) / 255,
      blue: CGFloat(hex & 0xFF) / 255,
      alpha: 1
    )
  }
}
