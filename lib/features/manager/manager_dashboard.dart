import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

import '../auth/bloc/auth_cubit.dart';
import 'bloc/manager_filter_cubit.dart';

class ManagerDashboardPage extends StatelessWidget {
  const ManagerDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => ManagerFilterCubit()..loadFilters(),
      child: const ManagerDashboardView(),
    );
  }
}

class ManagerDashboardView extends StatelessWidget {
  const ManagerDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manager Analytics'),
        backgroundColor: const Color(0xFF2563EB),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () => context.read<AuthCubit>().signOut(),
          )
        ],
      ),
      body: BlocBuilder<ManagerFilterCubit, ManagerFilterState>(
        builder: (context, state) {
          if (state.isLoading) {
            return const Center(child: CircularProgressIndicator(color: Color(0xFF00E676)));
          }

          final cubit = context.read<ManagerFilterCubit>();

          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  "Filter Station Data",
                  style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 24),

                // SINGLE FLATTENED DROPDOWN
                _buildDropdown<FlatFilterItem>(
                  hint: "Select a Specific Charging Gun",
                  value: state.selectedItem,
                  items: state.allItems,
                  getName: (FlatFilterItem item) => item.displayText,
                  onChanged: (val) => cubit.selectItem(val),
                ),

                const Spacer(),

                // ACTION BUTTON
                SizedBox(
                  width: double.infinity,
                  height: 55,
                  child: ElevatedButton(
                    onPressed: state.selectedItem == null
                        ? null
                        : () {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text("Fetching analytics for ${state.selectedItem!.gun.title}..."),
                          backgroundColor: const Color(0xFF2563EB),
                        ),
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF00E676),
                      disabledBackgroundColor: const Color(0xFF161B22),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                    child: Text(
                      "View Analytics",
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.bold,
                        color: state.selectedItem == null ? Colors.white54 : Colors.black,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildDropdown<T>({
    required String hint,
    required T? value,
    required List<T> items,
    required String Function(T) getName,
    required void Function(T?)? onChanged,
  }) {
    final bool isDisabled = onChanged == null;

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      decoration: BoxDecoration(
        color: isDisabled ? Colors.transparent : const Color(0xFF161B22),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: isDisabled ? Colors.white12 : Colors.white24,
        ),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<T>(
          isExpanded: true,
          hint: Text(hint, style: TextStyle(color: isDisabled ? Colors.white24 : Colors.white54)),
          value: value,
          dropdownColor: const Color(0xFF161B22),
          icon: Icon(Icons.arrow_drop_down, color: isDisabled ? Colors.white24 : Colors.white54),
          items: items.map((T item) {
            return DropdownMenuItem<T>(
              value: item,
              child: Text(getName(item), style: const TextStyle(color: Colors.white)),
            );
          }).toList(),
          onChanged: onChanged,
        ),
      ),
    );
  }
}