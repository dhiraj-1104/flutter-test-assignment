import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/event.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/state.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class CustomSearchBar extends StatelessWidget {
  final TextEditingController _searchController;
  const CustomSearchBar({super.key, required this._searchController});

  @override
  Widget build(BuildContext context) {
    return TextFormField(
      onTapOutside: (event) {
        FocusManager.instance.primaryFocus?.unfocus();
      },
      onChanged: (value) {
        context.read<UserBloc>().add(
          FilterUserEvent(query: _searchController.text),
        );
      },
      onFieldSubmitted: (value) {
        context.read<UserBloc>().add(
          FilterUserEvent(query: _searchController.text),
        );
      },
      controller: _searchController,
      inputFormatters: [
        FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z ]')),
      ],
      decoration: InputDecoration(hintText: "Search Names...."),
    );
  }
}
