import 'dart:io';

import 'package:mime/mime.dart';
import 'package:conduit/conduit.dart';
import 'package:hex/hex.dart';
import 'package:coschon/models/ad.dart';

class UploadController extends ResourceController {
  ManagedContext context;
  List<int> content = [];
  UploadController(this.context) {
    acceptedContentTypes = [ContentType("multipart", "form-data")];
  }
  @Operation.post()
  Future<Response> postForm() async {
    final boundary = request!.raw.headers.contentType!.parameters["boundary"]!;
    final transformer = MimeMultipartTransformer(boundary);
    final bodyBytes = await request!.body.decode<List<int>>();
    final bodyStream = Stream.fromIterable([bodyBytes]);
    final parts = await transformer.bind(bodyStream).toList();
    for (var part in parts) {
        final headers = part.headers;
        final body = await part.toList();
        final insertQuery = await Query<Ad>(context)
          ..values.contents = HEX.encode(body[0]);
        await insertQuery.insert();
    }
    return Response.ok("");
  }
  @Operation.get()
  Future<Response> getContent() async {
    final queryContent = await Query<Ad>(context);
    final qContent = await queryContent.fetchOne();
    return Response.ok(HEX.decode(qContent!.contents!))..contentType = ContentType("image", "jpeg");
  }
}