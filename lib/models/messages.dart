enum Type {
  text,
  image
}

class Message {
  Message({
    required this.toid,
    required this.msg,
    required this.read,
    required this.type,
    required this.fromid,
    required this.sent,
  });

  late String toid;
  late String msg;
  late String read;
  late Type type;
  late String fromid;
  late String sent;

  Message.fromJson(Map<String, dynamic> json) {
    toid = json['toid'].toString();
    msg = json['msg'].toString();
    read = json['read'].toString();
    type = json['type'] == 'image' ? Type.image : Type.text;
    fromid = json['fromid'].toString();
    sent = json['sent'].toString();
  }

  Map<String, dynamic> toJson() {
    final data = <String, dynamic>{};
    data['toid'] = toid;
    data['msg'] = msg;
    data['read'] = read;
    data['type'] = type == Type.image ? 'image' : 'text';
    data['fromid'] = fromid;
    data['sent'] = sent;
    return data;
  }
}
