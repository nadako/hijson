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

## Differences to other libraries:

 * `haxe.Json`/`haxe.format.JsonParser`
 * `hxjson`
 * `json2object`
 * `tink_json`
