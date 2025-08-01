import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/network_provider.dart';
import '../theme/app_colors.dart';
import 'loading_widget.dart';

class NetworkStatusWidget extends StatelessWidget {
  final bool showDetails;
  final bool showBanner;
  final VoidCallback? onRetry;

  const NetworkStatusWidget({
    super.key,
    this.showDetails = false,
    this.showBanner = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (!networkProvider.isInitialized) {
          return const SizedBox.shrink();
        }

        if (networkProvider.isConnected) {
          return _buildConnectedWidget(context, networkProvider);
        } else {
          return _buildDisconnectedWidget(context, networkProvider);
        }
      },
    );
  }

  Widget _buildConnectedWidget(BuildContext context, NetworkProvider networkProvider) {
    if (!showDetails) {
      return const SizedBox.shrink();
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: networkProvider.connectionColor.withValues(alpha: 0.1),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: networkProvider.connectionColor.withValues(alpha: 0.3),
        ),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            networkProvider.connectionIcon,
            size: 16,
            color: networkProvider.connectionColor,
          ),
          const SizedBox(width: 6),
          Text(
            networkProvider.connectionTypeString,
            style: Theme.of(context).textTheme.bodySmall?.copyWith(
              color: networkProvider.connectionColor,
              fontWeight: FontWeight.w500,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDisconnectedWidget(BuildContext context, NetworkProvider networkProvider) {
    if (!showBanner) {
      return const SizedBox.shrink();
    }

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.red,
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.1),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            networkProvider.connectionIcon,
            color: Colors.white,
            size: 20,
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'No Internet Connection',
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  'Please check your network settings and try again',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.9),
                  ),
                ),
              ],
            ),
          ),
          if (onRetry != null) ...[
            const SizedBox(width: 12),
            TextButton(
              onPressed: onRetry,
              style: TextButton.styleFrom(
                foregroundColor: Colors.white,
                backgroundColor: Colors.white.withValues(alpha: 0.2),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
              ),
              child: const Text('Retry'),
            ),
          ],
        ],
      ),
    );
  }
}

class NetworkAwareWidget extends StatelessWidget {
  final Widget child;
  final Widget? offlineWidget;
  final bool showNetworkStatus;
  final VoidCallback? onRetry;

  const NetworkAwareWidget({
    super.key,
    required this.child,
    this.offlineWidget,
    this.showNetworkStatus = true,
    this.onRetry,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, _) {
        if (!networkProvider.isInitialized) {
          return const LoadingPage(message: 'Initializing...');
        }

        if (!networkProvider.isConnected) {
          return Column(
            children: [
              if (showNetworkStatus)
                NetworkStatusWidget(
                  showBanner: true,
                  onRetry: onRetry,
                ),
              Expanded(
                child: offlineWidget ?? _buildDefaultOfflineWidget(context),
              ),
            ],
          );
        }

        return child;
      },
    );
  }

  Widget _buildDefaultOfflineWidget(BuildContext context) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.signal_wifi_off,
            size: 64,
            color: AppColors.getTextSecondary(context),
          ),
          const SizedBox(height: 16),
          Text(
            'No Internet Connection',
            style: Theme.of(context).textTheme.headlineSmall?.copyWith(
              color: AppColors.getTextPrimary(context),
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Please check your network connection\nand try again',
            textAlign: TextAlign.center,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: AppColors.getTextSecondary(context),
            ),
          ),
          const SizedBox(height: 24),
          if (onRetry != null)
            ElevatedButton.icon(
              onPressed: onRetry,
              icon: const Icon(Icons.refresh),
              label: const Text('Retry'),
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.dominantPurple,
                foregroundColor: Colors.white,
              ),
            ),
        ],
      ),
    );
  }
}

class NetworkStatusBar extends StatelessWidget {
  final bool showConnectionType;
  final bool showQuality;

  const NetworkStatusBar({
    super.key,
    this.showConnectionType = true,
    this.showQuality = false,
  });

  @override
  Widget build(BuildContext context) {
    return Consumer<NetworkProvider>(
      builder: (context, networkProvider, child) {
        if (!networkProvider.isInitialized || networkProvider.isConnected) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.red,
            boxShadow: [
              BoxShadow(
                color: Colors.black.withValues(alpha: 0.1),
                blurRadius: 2,
                offset: const Offset(0, 1),
              ),
            ],
          ),
          child: Row(
            children: [
              Icon(
                networkProvider.connectionIcon,
                color: Colors.white,
                size: 16,
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  'No internet connection',
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              if (showConnectionType) ...[
                Text(
                  networkProvider.connectionTypeString,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
              if (showQuality) ...[
                const SizedBox(width: 8),
                Text(
                  networkProvider.connectionQuality,
                  style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: Colors.white.withValues(alpha: 0.8),
                  ),
                ),
              ],
            ],
          ),
        );
      },
    );
  }
} 