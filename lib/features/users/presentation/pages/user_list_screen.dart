import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/features/users/domain/entities/user.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/bloc.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/event.dart';
import 'package:flutter_assignment/features/users/presentation/bloc/state.dart';
import 'package:flutter_assignment/features/users/presentation/pages/user_details_screen.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class UserListScreen extends StatefulWidget {
  const UserListScreen({super.key});

  @override
  State<UserListScreen> createState() => _UserListScreenState();
}

class _UserListScreenState extends State<UserListScreen> {
  final ScrollController _controller = ScrollController();
  final TextEditingController _searchController = TextEditingController();
  final GlobalKey<FormState> formKey = GlobalKey<FormState>();
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
                          searchBar(context),
                          userListViewBuilder(state),
                        ],
                      ),
                    ),
                  );
                } else if (state is UserError) {
                  return RefreshIndicator(
                    onRefresh: () async {
                      context.read<UserBloc>().add(GetUserEvent());
                    },
                    child: errorWidget(state),
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
                                searchBar(context),
                                userListViewBuilder(state),
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
                    child: errorWidget(state),
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

  LayoutBuilder errorWidget(UserError state) {
    return LayoutBuilder(
      builder: (context, constraints) {
        return SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          child: ConstrainedBox(
            constraints: BoxConstraints(minHeight: constraints.maxHeight),
            child: Center(child: Text(state.msg)),
          ),
        );
      },
    );
  }

  Expanded userListViewBuilder(UserLoaded state) {
    return Expanded(
      child: state.users.isEmpty
          ? Center(child: Text("No User Found!!"))
          : ListView.builder(
              controller: _controller,
              itemCount: state.users.length + (state.isFetching ? 1 : 0),

              itemBuilder: (context, index) {
                if (index >= state.users.length) {
                  return SizedBox(
                    height: 50,
                    width: 50,
                    child: Center(child: CircularProgressIndicator()),
                  );
                }

                final user = state.users[index];
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => UserDetailsScreen(user: user),
                      ),
                    );
                  },
                  child: Padding(
                    padding: const EdgeInsets.symmetric(vertical: 10),
                    child: Container(
                      padding: EdgeInsets.all(10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: Colors.grey),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 8,

                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            clipBehavior: Clip.antiAlias,
                            width: 50,
                            height: 50,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: CachedNetworkImage(imageUrl: user.imgUrl),
                          ),
                          SizedBox(width: 20),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [Text(user.firstName)],
                          ),
                          SizedBox(height: 5),
                        ],
                      ),
                    ),
                  ),
                );
              },
            ),
    );
  }

  Form searchBar(BuildContext context) {
    return Form(
      key: formKey,
      child: TextFormField(
        onChanged: (value) {
          if (!formKey.currentState!.validate()) {
            return;
          }
          context.read<UserBloc>().add(
            FilterUserEvent(query: _searchController.text),
          );
        },
        onFieldSubmitted: (value) {
          if (!formKey.currentState!.validate()) {
            return;
          }
          context.read<UserBloc>().add(
            FilterUserEvent(query: _searchController.text),
          );
        },
        controller: _searchController,
        validator: (value) {
          if (value == null || value.isEmpty) {
            return "The Input cannot be empty";
          }
          if (!RegExp(r'^[a-zA-Z]+$').hasMatch(value)) {
            return "Only alphabets are allowed";
          }
          return null;
        },
        decoration: InputDecoration(
          hintText: "Search Names....",
          suffixIcon: GestureDetector(
            onTap: () {
              if (!formKey.currentState!.validate()) {
                return;
              }
            },
            child: Icon(Icons.search),
          ),
          border: OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
        ),
      ),
    );
  }
}
