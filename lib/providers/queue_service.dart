import "package:queue/queue.dart";

class QueueService {
  final queue = Queue(delay: const Duration(milliseconds: 250));

  add(future) async {
    await queue.add(() => future);
  }
}
