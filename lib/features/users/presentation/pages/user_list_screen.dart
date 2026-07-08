import 'package:flutter/material.dart';
import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/event.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/state.dart';
import 'package:flutter_assignment/features/users/presentation/pages/user_details_screen.dart';
import 'package:flutter_assignment/features/users/presentation/widgets/loading_indicator.dart';
import 'package:flutter_assignment/features/users/presentation/widgets/search_bar.dart';
import 'package:flutter_assignment/features/users/presentation/widgets/user_list_tile.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  User? selectedUser;
  @override
  void initState() {
    context.read<UserBloc>().add(GetUserEvent());
    _controller.addListener(() {
      if (_controller.position.pixels >=
          _controller.position.maxScrollExtent - 200) {
        final blocState = context.read<UserBloc>().state;

        if (blocState is UserLoaded &&
            !blocState.hasReachedMax &&
            !blocState.isFetching) {
          context.read<UserBloc>().add(LoadUserEvent());
        }
      }
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,

      body: LayoutBuilder(
        builder: (context, constraints) {
          if (constraints.maxWidth < 500) {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return ConstrainedBox(
                        constraints: BoxConstraints(
                          minHeight: constraints.maxHeight,
                        ),
                        child: Center(child: CircularProgressIndicator()),
                      );
                    },
                  );
                } else if (state is UserLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 20,
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<UserBloc>().add(GetUserEvent());
                      },
                      child: Column(
                        children: [
                          CustomSearchBar(searchController: _searchController),
                          Expanded(
                            child: state.users.isEmpty
                                ? Center(child: Text("No User Found!!"))
                                : ListView.builder(
                                    controller: _controller,
                                    itemCount:
                                        state.users.length +
                                        (state.isFetching ? 1 : 0),

                                    itemBuilder: (context, index) {
                                      if (index >= state.users.length) {
                                        return LoadingIndicator();
                                      }

                                      final user = state.users[index];
                                      return UserListTile(
                                        user: user,
                                        onTap: () => Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (context) =>
                                                UserDetailsScreen(user: user),
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is UserError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(GetUserEvent());
                    },
                    child: ErrorWidget(state.msg),
                  );
                } else {
                  return Center(child: Text("404 Invalid"));
                }
              },
            );
          } else {
            return BlocBuilder<UserBloc, UserState>(
              builder: (context, state) {
                if (state is UserLoading) {
                  return LayoutBuilder(
                    builder: (context, constraints) {
                      return CircularProgressIndicator();
                    },
                  );
                } else if (state is UserLoaded) {
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                      vertical: 30.0,
                      horizontal: 20,
                    ),
                    child: RefreshIndicator(
                      onRefresh: () async {
                        context.read<UserBloc>().add(GetUserEvent());
                      },
                      child: Row(
                        children: [
                          Expanded(
                            child: Column(
                              children: [
                                CustomSearchBar(
                                  searchController: _searchController,
                                ),
                                Expanded(
                                  child: state.users.isEmpty
                                      ? Center(child: Text("No User Found!!"))
                                      : ListView.builder(
                                          controller: _controller,
                                          itemCount:
                                              state.users.length +
                                              (state.isFetching ? 1 : 0),

                                          itemBuilder: (context, index) {
                                            if (index >= state.users.length) {
                                              return LoadingIndicator();
                                            }

                                            final user = state.users[index];
                                            return UserListTile(
                                              user: user,
                                              onTap: () => Navigator.push(
                                                context,
                                                MaterialPageRoute(
                                                  builder: (context) =>
                                                      UserDetailsScreen(
                                                        user: user,
                                                      ),
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(
                            child: selectedUser == null
                                ? Center(child: Text("Select a user"))
                                : UserDetailsScreen(user: selectedUser!),
                          ),
                        ],
                      ),
                    ),
                  );
                } else if (state is UserError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(GetUserEvent());
                    },
                    child: ErrorWidget(state.msg),
                  );
                } else {
                  return Center(child: Text("404 Invalid"));
                }
              },
            );
          }
        },
      ),
    );
  }
}
