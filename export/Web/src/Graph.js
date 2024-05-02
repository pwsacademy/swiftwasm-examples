export default class Graph {
    #maxPoints;
    #points;
    #canvas;
    #padding;

    constructor(maxPoints, initialPoint, canvas, padding = 15) {
        this.#maxPoints = maxPoints;
        this.#points = [initialPoint];
        this.#canvas = canvas;
        this.#padding = padding;
    }

    get currentPoint() {
        return this.#points[this.#points.length - 1];
    }

    plot(newPoint) {
        this.#points.push(newPoint);
        if (this.#points.length > this.#maxPoints) {
            this.#points.shift();
        }
        this.#draw();
    }

    #draw() {
        const context = this.#canvas.getContext("2d");
        context.fillStyle = "hsl(20, 90%, 95%)";
        context.fillRect(0, 0, this.#canvas.width, this.#canvas.height);
        context.strokeStyle = "hsl(8, 86%, 58%)";
        context.lineWidth = 2;

        if (this.#points.length < 2) {
            return;
        }
        context.beginPath();
        context.moveTo(
            this.#padding,
            this.#canvas.height - this.#padding - this.#points[0]
        );
        const gap = (this.#canvas.width - 2 * this.#padding) / (this.#maxPoints - 1);
        for (let i = 1; i < this.#points.length; i++) {
            context.lineTo(
                this.#padding + i * gap,
                this.#canvas.height - this.#padding - this.#points[i]
            );
        }
        context.stroke();
    }
}
