# hijson: Inverted JSON parser for Haxe

[![Build Status](https://travis-ci.org/nadako/hijson.svg?branch=master)](https://travis-ci.org/nadako/hijson)

This is a variantion of `haxe.format.JsonParser` that gives the user full control over creation of parsed values.

**STATUS**: work in progress, subject to random changes, more docs to come

Required Haxe version: 4.0.0-rc.3 and later

API reference: https://nadako.github.io/hijson/

## About

The main idea of this library is that parsing the JSON data can be separated from building values
from it. So we introduce the concept of `Consumer` that consumes raw JSON values and produces some
value out of it. The `Parser` is then supplied with a `Consumer` instance and calls its method so
it can actually return values from the parser JSON data.

This way we _invert_ the control over JSON parsing, allowing user to plug in custom JSON processing logic
in a simple and efficient way.

## Usage

The parsing API could not be simplier:

```haxe
var value = hijson.Parser.parse('{"name": "Dan"}', myConsumer);
```

The most interesting here part is that `myConsumer` which is an instance of the [`Consumer`](https://nadako.github.io/hijson/hijson/Consumer.html)
interface that defines how the JSON is supposed to be parsed. The implementation must provide these methods:

```haxe
function consumeString(s:String):TResult;
function consumeNumber(n:String):TResult;
function consumeBool(b:Bool):TResult;
function consumeNull():TResult;
function consumeArray():TArrayContext;
function addArrayElement(context:TArrayContext, parser:Parser):Void;
function finalizeArray(context:TArrayContext):TResult;
function consumeObject():TObjectContext;
function addObjectField(context:TObjectContext, name:String, parser:Parser):Void;
function finalizeObject(context:TObjectContext):TResult;
```

These are the methods that are called by the `Parser` for producing values out of raw JSON data.

Of course, most of the real-world consumers would only work with a single JSON value kind,
so we have a handy [`BaseConsumer`](https://nadako.github.io/hijson/hijson/BaseConsumer.html) implementation
that implements the `Consumer` interface by throwing "unexpected value" errors in every method, which we can
then subclass and override the methods we're interested in.

We also provide a set of standard consumers for common Haxe types, like String, Int, Bool, Array, Map and so on. See the [API reference](https://nadako.github.io/hijson/) for details.

### Automagic consumers for custom types

**NOT IMPLEMENTED YET, see [#4](https://github.com/nadako/hijson/issues/4)**

Of course, writing `Consumer` implementations for custom data types, such as classes, enums and anonymous structures,
would be too annoying. So the plan is to implement a macro-based `Consumer` builder for these kinds of data types.

## Differences to other libraries:

 * `haxe.Json`/`haxe.format.JsonParser`
 * `hxjson`
 * `json2object`
 * `tink_json`
