//
//  CompassView.swift
//  Real, working SwiftUI compass with smooth animated needle/dial.
//
//  HOW TO USE
//  1. Drag this file into your Xcode project.
//  2. In Info.plist add:
//       Privacy - Location When In Use Usage Description
//       (e.g. "Used to show your heading and coordinates on the compass.")
//  3. Drop `CompassView()` into any view. That's it — no images required,
//     everything is vector-drawn so it stays crisp on every screen size.
//
//  import SwiftUI in the file that presents it, e.g.:
//     struct ContentView: View {
//         var body: some View { CompassView() }
//     }
//

import SwiftUI
internal import CoreLocation
internal import Combine

// MARK: - CompassManager
// Wraps CLLocationManager, publishes true/magnetic heading + coordinates,
// and does wrap-around-safe smoothing so 359° -> 1° never spins the needle
// the "long way" around.

final class CompassManager: NSObject, ObservableObject, CLLocationManagerDelegate {

    /// Current heading in degrees, ALWAYS normalized to 0..<360.
    /// Safe to use for text display and array/index lookups.
    @Published private(set) var heading: Double = 0
    /// Unbounded rotation value (can go negative or past 360) used only to
    /// drive `.rotationEffect` smoothly across the 0°/360° wrap. Never use
    /// this for indexing — use `heading` instead.
    @Published private(set) var rotation: Double = 0
    /// Latitude in degrees (nil until first location fix).
    @Published private(set) var latitude: Double?
    /// Longitude in degrees (nil until first location fix).
    @Published private(set) var longitude: Double?
    /// Whether the manager currently has a usable heading.
    @Published private(set) var isCalibrated: Bool = true
    /// Authorization state, in case you want to show a permission prompt.
    @Published private(set) var authorizationStatus: CLAuthorizationStatus

    private let manager = CLLocationManager()

    override init() {
        authorizationStatus = manager.authorizationStatus
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.headingFilter = 0.5   // degrees of change before a new callback fires
        manager.distanceFilter = 5    // meters
    }

    /// Call this from `.onAppear` (or a button) to start receiving updates.
    func start() {
        manager.requestWhenInUseAuthorization()
        if CLLocationManager.headingAvailable() {
            manager.startUpdatingHeading()
        }
        manager.startUpdatingLocation()
    }

    func stop() {
        manager.stopUpdatingHeading()
        manager.stopUpdatingLocation()
    }

    // MARK: CLLocationManagerDelegate

    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
        if authorizationStatus == .authorizedWhenInUse || authorizationStatus == .authorizedAlways {
            start()
        }
    }

    func locationManager(_ manager: CLLocationManager, didUpdateHeading newHeading: CLHeading) {
        isCalibrated = newHeading.headingAccuracy >= 0 && newHeading.headingAccuracy < 15
        // Prefer true heading when available (needs location fix), else magnetic.
        let raw = newHeading.trueHeading >= 0 ? newHeading.trueHeading : newHeading.magneticHeading
        setHeading(raw)
    }

    func locationManager(_ manager: CLLocationManager, didUpdateLocations locations: [CLLocation]) {
        guard let loc = locations.last else { return }
        latitude = loc.coordinate.latitude
        longitude = loc.coordinate.longitude
    }

    func locationManager(_ manager: CLLocationManager, didFailWithError error: Error) {
        // In production you might surface this to the UI.
        #if DEBUG
        print("CompassManager error: \(error.localizedDescription)")
        #endif
    }

    /// Sets heading while avoiding the 359°→0° animation "spin the wrong way" bug.
    /// `heading` is always written as a clean, normalized 0..<360 value (safe for
    /// text/index lookups). `rotation` is allowed to drift outside that range so
    /// the dial animates the short way around — it's for visuals only.
    private func setHeading(_ newValue: Double) {
        let normalizedNew = newValue.truncatingRemainder(dividingBy: 360)
        let clampedNew = normalizedNew < 0 ? normalizedNew + 360 : normalizedNew

        var delta = clampedNew - heading
        if delta > 180 { delta -= 360 }
        if delta < -180 { delta += 360 }

        withAnimation(.easeOut(duration: 0.18)) {
            rotation += delta
            heading = clampedNew   // always set directly — never accumulated
        }
    }

    /// Converts ANY degree value (including negative or >360) into a safe 0..<16 index.
    private static func compassIndex(for heading: Double) -> Int {
        let mod = heading.truncatingRemainder(dividingBy: 360)
        let positive = mod < 0 ? mod + 360 : mod          // guarantees 0..<360
        let raw = Int((positive / 22.5) + 0.5) % 16
        return raw < 0 ? raw + 16 : raw                    // guarantees 0..<16
    }

    /// 16-point compass label, e.g. "SW", "NNE". Safe for any input, including negative degrees.
    static func direction(for heading: Double) -> String {
        let dirs = ["N", "NNE", "NE", "ENE", "E", "ESE", "SE", "SSE",
                    "S", "SSW", "SW", "WSW", "W", "WNW", "NW", "NNW"]
        return dirs[compassIndex(for: heading)]
    }

    /// Long-form direction, e.g. "Southwest". Safe for any input, including negative degrees.
    static func longDirection(for heading: Double) -> String {
        let dirs = ["North", "North-Northeast", "Northeast", "East-Northeast",
                    "East", "East-Southeast", "Southeast", "South-Southeast",
                    "South", "South-Southwest", "Southwest", "West-Southwest",
                    "West", "West-Northwest", "Northwest", "North-Northwest"]
        return dirs[compassIndex(for: heading)]
    }
}

// MARK: - CompassView

struct CompassView: View {

    @StateObject private var compass = CompassManager()

    private let ringSize: CGFloat = screenWidth-50

    var body: some View {
        ZStack {
            VStack(spacing: 28) {
                headerSection
                dialSection
                coordinateCards
                Spacer(minLength: 8)
            }
            .padding(.top, 40)
            .padding(.horizontal, 24)
        }
        .onAppear { compass.start() }
        .onDisappear { compass.stop() }
    }

    // MARK: Header

    private var headerSection: some View {
        VStack(spacing: 8) {
            Text("\(Int(compass.heading.rounded()))° \(CompassManager.direction(for: compass.heading))")
                .font(.system(size: 40, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .contentTransition(.numericText())
                .animation(.easeOut(duration: 0.18), value: Int(compass.heading.rounded()))

            HStack(spacing: 6) {
                Text(CompassManager.longDirection(for: compass.heading))
                Text("•")
                Text(compass.isCalibrated ? Strings.highPrecision : Strings.calibrating)
            }
            .font(.system(size: 15, weight: .medium))
            .foregroundColor(.gray)
        }
    }

    // MARK: Dial

    private var dialSection: some View {
        ZStack {
            outerRing
            tickMarks
                .rotationEffect(.degrees(-compass.rotation))
            cardinalLetters
                .rotationEffect(.degrees(-compass.rotation))
            needle
            centerKnob
        }
        .frame(width: ringSize, height: ringSize)
        .padding(.vertical, 8)
    }

    private var outerRing: some View {
        ZStack {
            Circle()
                .fill(
                    RadialGradient(
                        colors: [.clear]/*[Color(white: 0.16), Color(white: 0.08)]*/,
                        center: .center, startRadius: 10, endRadius: ringSize / 2
                    )
                )
                .overlay(
                    Circle().stroke(Color(white: 0.28), lineWidth: 1)
                )

            Circle()
                .fill(.clear)
                .padding(18)
                .overlay(
                    Circle().stroke(Color(white: 0.22), lineWidth: 1).padding(34)
                )

//            Circle()
//                .stroke(Color(white: 0.3), lineWidth: 10)
//                .padding(4)
        }
    }

    /// 72 tick marks (every 5°), longer/brighter every 30°.
    private var tickMarks: some View {
        Canvas { context, size in
            let center = CGPoint(x: size.width / 2, y: size.height / 2)
            let radius = size.width / 2

            for i in 0..<72 {
                let degrees = Double(i) * 5
                let isMajor = Int(degrees) % 30 == 0
                let isMinor = Int(degrees) % 10 == 0

                let tickLength: CGFloat = isMajor ? 16 : (isMinor ? 11 : 6)
                let tickWidth: CGFloat = isMajor ? 2 : 1
                let opacity: Double = isMajor ? 0.9 : (isMinor ? 0.55 : 0.3)

                let outer = radius - 14
                let inner = outer - tickLength

                let angle = Angle(degrees: degrees - 90).radians
                let p1 = CGPoint(x: center.x + cos(angle) * outer,
                                  y: center.y + sin(angle) * outer)
                let p2 = CGPoint(x: center.x + cos(angle) * inner,
                                  y: center.y + sin(angle) * inner)

                var path = Path()
                path.move(to: p1)
                path.addLine(to: p2)

                context.stroke(path, with: .color(.white.opacity(opacity)), lineWidth: tickWidth)
            }
        }
        .padding(2)
    }

    private var cardinalLetters: some View {
        GeometryReader { geo in
            let radius = geo.size.width / 2 - 44
            let center = CGPoint(x: geo.size.width / 2, y: geo.size.height / 2)

            ForEach(cardinalPoints, id: \.label) { point in
                Text(point.label)
                    .font(.custom("Georgia-Bold", size: point.label.count > 1 ? 15 : 24))
                    .foregroundColor(point.label.count > 1 ? Color(white: 0.65) : point.label == "N" ? . red : .white)
                    .rotationEffect(.degrees(compass.rotation))
                    .position(
                        x: center.x + CGFloat(cos(point.angleRadians)) * radius,
                        y: center.y + CGFloat(sin(point.angleRadians)) * radius
                    )
            }
        }
    }

    private struct CardinalPoint {
        let label: String
        let angleRadians: Double
    }

    private var cardinalPoints: [CardinalPoint] {
        let majors = ["N", "E", "S", "W"]
        let minors = ["NE", "SE", "SW", "NW"]
        var points: [CardinalPoint] = []
        for (i, label) in majors.enumerated() {
            points.append(CardinalPoint(label: label, angleRadians: Angle(degrees: Double(i) * 90 - 90).radians))
        }
        for (i, label) in minors.enumerated() {
            points.append(CardinalPoint(label: label, angleRadians: Angle(degrees: Double(i) * 90 - 45).radians))
        }
        return points
    }

    /// Fixed needle: red half points to true/magnetic north (device heading),
    /// blue half points south. Stays pointing "up" — the dial rotates around it,
    /// exactly like Apple's own Compass app.
    private var needle: some View {
        NeedleShape()
            .fill(
                LinearGradient(
                    stops: [
                        .init(color: Color(red: 0.85, green: 0.15, blue: 0.15), location: 0.0),
                        .init(color: Color(red: 0.85, green: 0.15, blue: 0.15), location: 0.5),
                        .init(color: Color(red: 0.15, green: 0.25, blue: 0.85), location: 0.5),
                        .init(color: Color(red: 0.15, green: 0.25, blue: 0.85), location: 1.0)
                    ],
                    startPoint: .top, endPoint: .bottom
                )
            )
            .frame(width: 28, height: ringSize - 150)
            .shadow(color: .black.opacity(0.5), radius: 6, x: 0, y: 2)
    }

    private var centerKnob: some View {
        ZStack {
            Circle().fill(Color(white: 0.15)).frame(width: 26, height: 26)
            Circle().fill(Color.white).frame(width: 20, height: 20)
            Circle().stroke(Color(white: 0.3), lineWidth: 2).frame(width: 26, height: 26)
        }
        .shadow(color: .black.opacity(0.4), radius: 4)
    }

    // MARK: Coordinate cards

    private var coordinateCards: some View {
        HStack(spacing: 14) {
            coordinateCard(title: Strings.latitude, value: formatted(compass.latitude, isLat: true))
            coordinateCard(title: Strings.longtitude, value: formatted(compass.longitude, isLat: false))
        }
    }

    private func coordinateCard(title: String, value: String) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(title)
                .font(.system(size: 13, weight: .medium))
                .foregroundColor(.gray)
            Text(value)
                .font(.system(size: 18, weight: .semibold, design: .rounded))
                .foregroundColor(.white)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(16)
        .background(
            RoundedRectangle(cornerRadius: 16, style: .continuous)
                .fill(Color(white: 0.1))
                .overlay(
                    RoundedRectangle(cornerRadius: 16, style: .continuous)
                        .stroke(Color(white: 0.18), lineWidth: 1)
                )
        )
    }

    private func formatted(_ value: Double?, isLat: Bool) -> String {
        guard let value else { return "—" }
        let suffix: String
        if isLat {
            suffix = value >= 0 ? "N" : "S"
        } else {
            suffix = value >= 0 ? "E" : "W"
        }
        return String(format: "%.4f° %@", abs(value), suffix)
    }
}

// MARK: - Needle Shape
// A slim kite/diamond, like the reference design: pointed top & bottom,
// widest at the vertical midpoint.

private struct NeedleShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let w = rect.width
        let h = rect.height
        let midY = h / 2

        path.move(to: CGPoint(x: w / 2, y: 0))                 // top point
        path.addLine(to: CGPoint(x: w, y: midY))                // right mid
        path.addLine(to: CGPoint(x: w / 2, y: h))               // bottom point
        path.addLine(to: CGPoint(x: 0, y: midY))                // left mid
        path.closeSubpath()
        return path
    }
}

// MARK: - Preview

#Preview {
    CompassView()
        .preferredColorScheme(.dark)
}
