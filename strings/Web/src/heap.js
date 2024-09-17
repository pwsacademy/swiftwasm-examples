export default class Heap {

    #nextID = 1;
    #map = new Map();

    store(data) {
        const id = this.#nextID++;
        this.#map.set(id, data);
        return id;
    }

    get(reference) {
        let data = this.#map.get(reference);
        this.#map.delete(reference);
        return data;
    }
}
