import QtQuick
import QtQuick.Shapes
import qs.DankCommon.Common

Item {
    id: root

    property string shape: "cookie4"
    property color color: Style.primary
    property int samplesPerLobe: 14

    readonly property var catalog: ({
            "circle": {
                "lobes": 0
            },
            "square": {
                "polygon": 4,
                "roundness": 0.55,
                "phase": Math.PI / 4
            },
            "cookie4": {
                "lobes": 4,
                "depth": 0.12
            },
            "cookie6": {
                "lobes": 6,
                "depth": 0.1
            },
            "cookie7": {
                "lobes": 7,
                "depth": 0.09
            },
            "cookie9": {
                "lobes": 9,
                "depth": 0.08
            },
            "cookie12": {
                "lobes": 12,
                "depth": 0.06
            },
            "clover4": {
                "lobes": 4,
                "depth": 0.3
            },
            "clover8": {
                "lobes": 8,
                "depth": 0.18
            },
            "flower": {
                "lobes": 8,
                "depth": 0.14
            },
            "sunny": {
                "lobes": 8,
                "depth": 0.22
            },
            "burst": {
                "lobes": 10,
                "depth": 0.2
            },
            "gem": {
                "polygon": 6,
                "roundness": 0.4,
                "phase": 0
            },
            "diamond": {
                "polygon": 4,
                "roundness": 0.45,
                "phase": 0
            },
            "pentagon": {
                "polygon": 5,
                "roundness": 0.4,
                "phase": -Math.PI / 2
            }
        })
    readonly property string pathData: buildPath(shape, width, height)

    implicitWidth: Style.iconButtonSize
    implicitHeight: Style.iconButtonSize

    function radiusAt(spec, theta) {
        if (spec.polygon) {
            const n = spec.polygon;
            const a = (((theta - spec.phase) % (2 * Math.PI / n)) + 2 * Math.PI / n) % (2 * Math.PI / n);
            const poly = Math.cos(Math.PI / n) / Math.cos(a - Math.PI / n);
            return poly + (1 - poly) * spec.roundness;
        }
        if (!spec.lobes)
            return 1;
        return 1 - spec.depth * (1 - Math.cos(spec.lobes * theta)) / 2;
    }

    function buildPath(kind, w, h) {
        if (w <= 0 || h <= 0)
            return "";
        const spec = catalog[kind] ?? catalog.circle;
        const count = Math.max(48, samplesPerLobe * (spec.lobes || spec.polygon || 4));
        const rx = w / 2;
        const ry = h / 2;
        const pts = [];
        for (let i = 0; i < count; i++) {
            const theta = i / count * 2 * Math.PI;
            const r = radiusAt(spec, theta);
            pts.push({
                "x": rx + rx * r * Math.cos(theta),
                "y": ry + ry * r * Math.sin(theta)
            });
        }
        const f = v => v.toFixed(2);
        let d = "M " + f(pts[0].x) + " " + f(pts[0].y);
        for (let i = 0; i < count; i++) {
            const p0 = pts[(i - 1 + count) % count];
            const p1 = pts[i];
            const p2 = pts[(i + 1) % count];
            const p3 = pts[(i + 2) % count];
            const c1x = p1.x + (p2.x - p0.x) / 6;
            const c1y = p1.y + (p2.y - p0.y) / 6;
            const c2x = p2.x - (p3.x - p1.x) / 6;
            const c2y = p2.y - (p3.y - p1.y) / 6;
            d += " C " + f(c1x) + " " + f(c1y) + " " + f(c2x) + " " + f(c2y) + " " + f(p2.x) + " " + f(p2.y);
        }
        return d + " Z";
    }

    Shape {
        anchors.fill: parent
        preferredRendererType: Shape.CurveRenderer

        ShapePath {
            strokeColor: "transparent"
            strokeWidth: 0
            fillColor: root.color

            PathSvg {
                path: root.pathData
            }
        }
    }
}
