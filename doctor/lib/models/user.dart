class EhrUser {
  final String name;
  final String email;
  final String publickey;
  final String privatekey;
  final String imageurl;
  final String location;
  final String joindate;

  EhrUser({
    this.name,
    this.email,
    this.imageurl,
    this.location,
    this.joindate,
    this.privatekey,
    this.publickey,
  });
}
