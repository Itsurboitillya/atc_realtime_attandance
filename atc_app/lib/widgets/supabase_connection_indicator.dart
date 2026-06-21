import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../services/supabase_connection_service.dart';

class SupabaseConnectionIndicator extends StatelessWidget {
  final bool showLabel;

  const SupabaseConnectionIndicator({super.key, this.showLabel = true});

  @override
  Widget build(BuildContext context) {
    return Consumer<SupabaseConnectionService>(
      builder: (context, connectionService, _) {
        final color = connectionService.getStatusColor();
        final status = connectionService.getStatusText();
        final isSending = connectionService.isSendingData;

        return GestureDetector(
          onTap: () {
            // Recheck connection on tap
            connectionService.checkConnection();
            
            // Show connection status dialog
            showDialog(
              context: context,
              builder: (ctx) => AlertDialog(
                title: const Text('Supabase Connection Status'),
                content: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 12,
                          height: 12,
                          decoration: BoxDecoration(
                            color: color,
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 8),
                        Text(
                          status,
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    if (isSending)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Row(
                          children: [
                            const SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Text('Sending data to Supabase...'),
                          ],
                        ),
                      ),
                    if (connectionService.lastError.isNotEmpty)
                      Padding(
                        padding: const EdgeInsets.only(top: 12),
                        child: Text(
                          'Error: ${connectionService.lastError}',
                          style: const TextStyle(
                            color: Colors.red,
                            fontSize: 12,
                          ),
                        ),
                      ),
                  ],
                ),
                actions: [
                  TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Close'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      connectionService.checkConnection();
                      Navigator.pop(ctx);
                    },
                    child: const Text('Retry'),
                  ),
                ],
              ),
            );
          },
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: color.withAlpha(25),
              border: Border.all(color: color, width: 1.5),
              borderRadius: BorderRadius.circular(2),
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: color,
                    shape: BoxShape.circle,
                  ),
                  child: isSending
                      ? const SizedBox(
                          child: CircularProgressIndicator(
                            strokeWidth: 1,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              Colors.white,
                            ),
                          ),
                        )
                      : null,
                ),
                if (showLabel) ...[
                  const SizedBox(width: 6),
                  Text(
                    status,
                    style: TextStyle(
                      color: color,
                      fontSize: 12,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ],
              ],
            ),
          ),
        );
      },
    );
  }
}
