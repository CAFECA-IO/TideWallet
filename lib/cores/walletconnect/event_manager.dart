part of 'core.dart';

class Event {
  final String evt;
  final Function callback;

  Event(this.evt, this.callback);
}

class EventManager {
  final List<Event> _events = [];

  trigger(String evt, { dynamic value }) {
    Log.debug('Trigger $evt');
    final evts = this._events.where((event) => event.evt == evt);
  
    evts.toList().forEach((e) {
      e.callback(value);
    });
  }

  subscribe(Event event) {
    this._events.add(event);
  }

  unsubscribe(String evt) {
    this._events.removeWhere((event) => event.evt == evt);
  }
}
