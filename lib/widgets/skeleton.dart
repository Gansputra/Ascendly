import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class Skeleton extends StatelessWidget {
  final double? height;
  final double? width;
  final double borderRadius;

  const Skeleton({
    super.key,
    this.height,
    this.width,
    this.borderRadius = 16,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.white.withOpacity(0.05) : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.white.withOpacity(0.1) : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Container(
        height: height,
        width: width,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(borderRadius),
        ),
      ),
    );
  }
}

class SocialSkeleton extends StatelessWidget {
  const SocialSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 6,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            const Skeleton(height: 50, width: 50, borderRadius: 25),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Skeleton(height: 16, width: MediaQuery.of(context).size.width * 0.4),
                  const SizedBox(height: 8),
                  Skeleton(height: 12, width: MediaQuery.of(context).size.width * 0.2),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class StatsSkeleton extends StatelessWidget {
  const StatsSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(child: Skeleton(height: 100)),
              const SizedBox(width: 16),
              Expanded(child: Skeleton(height: 100)),
            ],
          ),
          const SizedBox(height: 32),
          Skeleton(height: 24, width: 150),
          const SizedBox(height: 16),
          Skeleton(height: 300),
          const SizedBox(height: 32),
          Skeleton(height: 24, width: 120),
          const SizedBox(height: 16),
          Skeleton(height: 200),
        ],
      ),
    );
  }
}

class DashboardSkeleton extends StatelessWidget {
  const DashboardSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Skeleton(height: 24, width: 150),
                    const SizedBox(height: 8),
                    Skeleton(height: 14, width: 100),
                  ],
                ),
                const Skeleton(height: 40, width: 40, borderRadius: 20),
              ],
            ),
            const SizedBox(height: 40),
            Skeleton(height: 200, borderRadius: 32),
            const SizedBox(height: 32),
            Skeleton(height: 100, borderRadius: 24),
            const SizedBox(height: 32),
            Skeleton(height: 80, borderRadius: 24),
            const SizedBox(height: 40),
            Center(child: Skeleton(height: 56, width: 200, borderRadius: 28)),
          ],
        ),
      ),
    );
  }
}

class ProfileSkeleton extends StatelessWidget {
  const ProfileSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        children: [
          const Center(child: Skeleton(height: 100, width: 100, borderRadius: 50)),
          const SizedBox(height: 24),
          Skeleton(height: 24, width: 150),
          const SizedBox(height: 8),
          Skeleton(height: 14, width: 200),
          const SizedBox(height: 40),
          ...List.generate(4, (index) => Padding(
            padding: const EdgeInsets.only(bottom: 12),
            child: Skeleton(height: 70),
          )),
          const SizedBox(height: 48),
          Skeleton(height: 56),
        ],
      ),
    );
  }
}

class ListSkeleton extends StatelessWidget {
  const ListSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(24),
      itemCount: 8,
      itemBuilder: (context, index) => Padding(
        padding: const EdgeInsets.only(bottom: 12),
        child: Skeleton(height: 80),
      ),
    );
  }
}

class GridSkeleton extends StatelessWidget {
  const GridSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return GridView.builder(
      padding: const EdgeInsets.all(24),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3,
        crossAxisSpacing: 16,
        mainAxisSpacing: 24,
        childAspectRatio: 0.8,
      ),
      itemCount: 12,
      itemBuilder: (context, index) => Column(
        children: [
          const Expanded(child: Skeleton(borderRadius: 40)),
          const SizedBox(height: 10),
          Skeleton(height: 12, width: 60),
        ],
      ),
    );
  }
}

class ChatSkeleton extends StatelessWidget {
  const ChatSkeleton({super.key});

  @override
  Widget build(BuildContext context) {
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: 10,
      itemBuilder: (context, index) {
        final isMe = index % 2 == 0;
        return Align(
          alignment: isMe ? Alignment.centerRight : Alignment.centerLeft,
          child: Padding(
            padding: const EdgeInsets.only(bottom: 16),
            child: Skeleton(
              height: 40,
              width: MediaQuery.of(context).size.width * (0.3 + (index % 4) * 0.1),
              borderRadius: 16,
            ),
          ),
        );
      },
    );
  }
}
