part of 'core.dart';

class Event {
  final String evt;
  final Function callback;

  Event(this.evt, this.callback);
}

class EventManager {
  final List<Event> _events = [];

  trigger(String evt, { dynamic value }) {
    final evtIndex = this._events.indexWhere((event) => event.evt == evt);
    if (evtIndex > -1) {
      this._events[evtIndex].callback(value);
    }
  }

  subscribe(Event event) {
    this._events.add(event);
  }

  unsubscribe(String evt) {
    this._events.removeWhere((event) => event.evt == evt);
  }
}
