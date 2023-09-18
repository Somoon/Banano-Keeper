import "package:queue/queue.dart";

class QueueService {
  final queue = Queue(delay: const Duration(milliseconds: 500));

  add(future) {
    queue.add(() => future);
  }
}
