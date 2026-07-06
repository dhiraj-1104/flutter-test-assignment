import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter_assignment/features/users/domain/entities/user.dart';

class UserDetailsScreen extends StatefulWidget {
  final User? _user;
  const UserDetailsScreen({super.key, this._user});

  @override
  State<UserDetailsScreen> createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  bool isImageShown = false;

  @override
  Widget build(BuildContext context) {
    return (widget._user != null)
        ? Scaffold(
            appBar: AppBar(
              centerTitle: true,
              title: Text(widget._user!.firstName),
            ),
            body: Padding(
              padding: const EdgeInsets.symmetric(
                vertical: 30.0,
                horizontal: 20,
              ),
              child: Stack(
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          isImageShown = !isImageShown;
                          setState(() {});
                        },
                        child: AspectRatio(
                          aspectRatio: 4 / 2,
                          child: Container(
                            clipBehavior: Clip.antiAlias,
                            decoration: BoxDecoration(shape: BoxShape.circle),
                            child: CachedNetworkImage(
                              imageUrl: widget._user!.imgUrl,
                              fit: BoxFit.contain,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 10),
                      Text(
                        "${widget._user!.firstName} ${widget._user!.lastName}",
                        style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      Text(
                        widget._user!.email,
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                          color: Colors.grey,
                        ),
                      ),
                    ],
                  ),
                  isImageShown
                      ? Container(
                          decoration: BoxDecoration(color: Colors.white),

                          width: 500,
                          height: 500,
                          child: CachedNetworkImage(
                            imageUrl: widget._user!.imgUrl,
                            fit: BoxFit.contain,
                          ),
                        )
                      : SizedBox(),
                  isImageShown
                      ? Positioned(
                          top: 10,
                          left: 10,
                          child: GestureDetector(
                            onTap: () {
                              isImageShown = !isImageShown;
                              setState(() {});
                            },
                            child: Align(child: Icon(Icons.close)),
                          ),
                        )
                      : SizedBox(),
                ],
              ),
            ),
          )
        : Scaffold(body: Center(child: Text("Tap the user to see details")));
  }
}
