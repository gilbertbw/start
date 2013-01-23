library response;

import 'dart:io' hide Cookie;
import 'dart:json';

import 'cookie.dart';

class Response {
  HttpResponse _response;
  var _view;

  Response(this._response, [this._view]);

  header(String name, [value]) {
    if (value == null) {
      return _response.headers[name];
    }
    _response.headers.set(name, value);
    return this;
  }

  Response get(String name) => header(name);

  Response set(name, value) => header(name, value);

  Response type(contentType) => set('Content-Type', contentType);

  Response cache(String cacheType, [Map options]) {
    if(options == null) {
      options = {};
    }
    StringBuffer value = new StringBuffer(cacheType);
    options.forEach((key, val) {
      value.add(', ${key}=${val}');
    });
    return set('Cache-Control', value.toString());
  }

  Response status(code) {
    _response.statusCode = code;
    return this;
  }

  Response cookie(name, val, [Map options]) {
    if (options == null) {
      options = {};
    }
    options['name'] = name;
    options['value'] = val;
    var cookieHeader = Cookie.stringify(options);
    return header('Set-Cookie', cookieHeader);
  }

  Response deleteCookie(name) {
    Map options = { 'expires': 'Thu, 01-Jan-70 00:00:01 GMT', 'path': '/' };
    return cookie(name, '', options);
  }

  send(String string) {
    _response.outputStream.write(string.charCodes);
    _response.outputStream.close();
  }

  sendFile(path) {
    var file = new File(path);
    file.exists().then((found) {
      if (found) {
        file.openInputStream().pipe(_response.outputStream);
      } else {
        _response.statusCode = HttpStatus.NOT_FOUND;
        _response.outputStream.close();
      }
    });
  }

  json(data) {
    if(data is Map) {
      data = stringify(data);
    }
    send(data);
  }

  redirect(url, [int code = 302]) {
    _response.statusCode = code;
    header('Location', url);
    _response.outputStream.close();
  }

  render(String viewName, [Map params]) {
    header('Content-Type', 'text/html; charset=UTF-8')
    .send(_view.render(viewName, params));
  }
}
