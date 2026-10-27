import AppKit

let size = 1024.0
let outputDirectory = URL(fileURLWithPath: CommandLine.arguments.count > 1 ? CommandLine.arguments[1] : "icon.iconset", isDirectory: true)
try FileManager.default.createDirectory(at: outputDirectory, withIntermediateDirectories: true)

let image = NSImage(size: NSSize(width: size, height: size))
image.lockFocus()
guard let context = NSGraphicsContext.current?.cgContext else { fatalError("No graphics context") }

let fullRect = CGRect(x: 0, y: 0, width: size, height: size)
let squircle = CGPath(roundedRect: fullRect, cornerWidth: 226, cornerHeight: 226, transform: nil)
context.addPath(squircle)
context.clip()

let background = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        CGColor(red: 0.98, green: 0.99, blue: 0.99, alpha: 1),
        CGColor(red: 0.84, green: 0.93, blue: 0.91, alpha: 1)
    ] as CFArray,
    locations: [0, 1]
)!
context.drawLinearGradient(
    background,
    start: CGPoint(x: 0, y: size),
    end: CGPoint(x: 0, y: 0),
    options: []
)

context.setFillColor(CGColor(red: 0.06, green: 0.46, blue: 0.43, alpha: 0.08))
context.fillEllipse(in: CGRect(x: -80, y: 560, width: 760, height: 760))

context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -20), blur: 36, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.28))

let folderColor = CGColor(red: 0.08, green: 0.47, blue: 0.43, alpha: 1)
let folderRect = CGRect(x: 150, y: 270, width: 620, height: 390)
context.addPath(CGPath(roundedRect: folderRect, cornerWidth: 72, cornerHeight: 72, transform: nil))
context.setFillColor(folderColor)
context.fillPath()

let tabRect = CGRect(x: 150, y: 600, width: 250, height: 96)
context.addPath(CGPath(roundedRect: tabRect, cornerWidth: 42, cornerHeight: 42, transform: nil))
context.setFillColor(folderColor)
context.fillPath()
context.restoreGState()

let folderAccent = CGGradient(
    colorsSpace: CGColorSpaceCreateDeviceRGB(),
    colors: [
        CGColor(red: 0.13, green: 0.62, blue: 0.57, alpha: 1),
        CGColor(red: 0.05, green: 0.40, blue: 0.37, alpha: 1)
    ] as CFArray,
    locations: [0, 1]
)!
context.saveGState()
context.addPath(CGPath(roundedRect: CGRect(x: 150, y: 270, width: 620, height: 390), cornerWidth: 72, cornerHeight: 72, transform: nil))
context.clip()
context.drawLinearGradient(
    folderAccent,
    start: CGPoint(x: 0, y: 660),
    end: CGPoint(x: 0, y: 270),
    options: []
)
context.restoreGState()

context.saveGState()
context.setShadow(offset: CGSize(width: 0, height: -14), blur: 28, color: CGColor(red: 0, green: 0, blue: 0, alpha: 0.22))
let panelRect = CGRect(x: 420, y: 180, width: 390, height: 340)
context.addPath(CGPath(roundedRect: panelRect, cornerWidth: 48, cornerHeight: 48, transform: nil))
context.setFillColor(CGColor(red: 0.99, green: 0.99, blue: 0.99, alpha: 1))
context.fillPath()
context.restoreGState()

let lineX = 492.0
let lineWidths = [238.0, 190.0, 144.0]
for (index, width) in lineWidths.enumerated() {
    let y = 430.0 - Double(index) * 82.0
    let rect = CGRect(x: lineX, y: y, width: width, height: 34)
    let color = index == 0
        ? CGColor(red: 0.06, green: 0.46, blue: 0.43, alpha: 1)
        : CGColor(red: 0.55, green: 0.61, blue: 0.62, alpha: 1)
    context.addPath(CGPath(roundedRect: rect, cornerWidth: 17, cornerHeight: 17, transform: nil))
    context.setFillColor(color)
    context.fillPath()
}

context.setLineWidth(10)
context.setStrokeColor(CGColor(red: 0.06, green: 0.36, blue: 0.34, alpha: 0.16))
context.addPath(squircle)
context.strokePath()

image.unlockFocus()

guard let tiff = image.tiffRepresentation,
      let bitmap = NSBitmapImageRep(data: tiff),
      let png = bitmap.representation(using: .png, properties: [:]) else {
    fatalError("Could not render icon")
}

let sizes: [(String, Int)] = [
    ("icon_16x16.png", 16),
    ("icon_16x16@2x.png", 32),
    ("icon_32x32.png", 32),
    ("icon_32x32@2x.png", 64),
    ("icon_128x128.png", 128),
    ("icon_128x128@2x.png", 256),
    ("icon_256x256.png", 256),
    ("icon_256x256@2x.png", 512),
    ("icon_512x512.png", 512),
    ("icon_512x512@2x.png", 1024)
]

for (name, pixelSize) in sizes {
    let resizedImage = NSImage(size: NSSize(width: pixelSize, height: pixelSize))
    resizedImage.lockFocus()
    image.draw(in: NSRect(x: 0, y: 0, width: pixelSize, height: pixelSize))
    resizedImage.unlockFocus()

    guard let resizedTiff = resizedImage.tiffRepresentation,
          let resizedBitmap = NSBitmapImageRep(data: resizedTiff),
          let resizedPNG = resizedBitmap.representation(using: .png, properties: [:]) else {
        fatalError("Could not render \(name)")
    }

    try resizedPNG.write(to: outputDirectory.appendingPathComponent(name))
}

_ = png
