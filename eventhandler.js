class EventHandlerPrototype {
	events_handlers = new Object();

	on(event_name, callback) {
		if (!(event_name in this.events_handlers)) {
			this.events_handlers[event_name] = [];
		}
		var exists = false;
		for (let [i, f] of Object.entries(this.events_handlers[event_name])){
			if (callback.toString() == f.toString()) {
				exists = true;
				break;
			}
		}
		if (!exists) this.events_handlers[event_name].push(callback);
	}
	fireEvent(event_name, obj){
		if (event_name in this.events_handlers){
			for (var i in this.events_handlers[event_name]){
				var f = this.events_handlers[event_name][i];
				if (typeof(f) == 'function') f(this, obj);
				else this.events_handlers[event_name].splice(i, 1);
			}
		}
	}
}
