// lib/common/screen/navigation_container.dart

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../bloc/navigation/navigation_cubit.dart';

class NavigationContainer extends StatelessWidget {
  const NavigationContainer({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => NavigationCubit(),
      child: Scaffold(
        body: _buildBody(),
        bottomNavigationBar: _buildBottomNavigationBar(context),
      ),
    );
  }
}

Widget _buildBody() {
  return BlocBuilder<NavigationCubit, int>(
    builder: (context, index) {
      final pages = _pages();
      return IndexedStack(index: index, children: pages);
    },
  );
}

List<Widget> _pages() => [
  _pagePlaceholder('Home'),
  _pagePlaceholder('Search'),
  _pagePlaceholder('Profile'),
];

Widget _pagePlaceholder(String title) {
  return Center(child: Text(title));
}

Widget _buildBottomNavigationBar(BuildContext context) {
  return BlocBuilder<NavigationCubit, int>(
    builder: (context, index) {
      return BottomNavigationBar(
        currentIndex: index,
        onTap: (i) => context.read<NavigationCubit>().updateIndex(i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Search'),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Profile'),
        ],
      );
    },
  );
}
