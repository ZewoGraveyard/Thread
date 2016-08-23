# Thread

[![Swift][swift-badge]][platform-url] [![Zewo][zewo-badge]][zewo-url] [![Platform][platform-badge]][platform-url] [![License][mit-badge]][mit-url] [![Slack][slack-badge]][slack-url] [![Travis][travis-badge]][travis-url] [![Codebeat][codebeat-badge]][codebeat-url]

## Overview

**Thread** is a concise and type-safe wrapper around the POSIX `pthread` API.

## Installation

```swift
import PackageDescription

let package = Package(
    dependencies: [
        .Package(url: "https://github.com/Zewo/Thread.git", majorVersion: 0, minor: 7),
    ]
)
```

Compiles with the `05-09` snapshot. Compatibility with other versions of Swift is not guaranteed.

## Usage

Most methods have doc comments which can be another helpful source of documentation. Unit tests can also be used as examples.

### Creating a thread

```swift
let thread = try Thread {
    print("I'm on a different thread!")
}
```

The closure passed to the `Thread` initializer is immediately executed on a new thread.

### Waiting for the result

```swift
let thread = try Thread<Int> {
     return [1, 2, 3, 4, 5].reduce(0, combine: +)
}
let sum = try thread.wait() // 15
```

The `wait` method suspends the execution of the current thread until the called thread exits. It then returns the result of the routine given to the thread.

> **WARNING**: Manual calls to `pthread_exit` with a non-nil parameter are almost guaranteed to crash your application.

### Using a lock

A lock is a simple concurrency primitive which can be used to achieve thread-safety.

The lock can be locked with `acquire` and unlocked with `release`. The `withLock` method acquires the lock for the duration of the passed in closure.

```swift
let lock = try Lock()
var shared = 0
for _ in 1...1000 {
  try Thread {
      try lock.withLock {
          shared += 1
      }
  }
}
```

### Using locks with conditions

A condition is a concurrency primitive which can be used to notify other threads when an action occurs.

```swift
let delay = try Condition()
let lock = try Lock()
try Thread {
    sleep(1)
    delay.resolve()
}
try lock.withLock {
    lock.wait(for: delay)
}
```

## Support

If you need any help you can join our [Slack][slack-url] and go to the **#help** channel. Or you can create a Github [issue](https://github.com/Zewo/Zewo/issues/new) in our main repository. When stating your issue be sure to add enough details, specify what module is causing the problem and reproduction steps.

## Community

[![Slack][slack-image]][slack-url]

The entire Zewo code base is licensed under MIT. By contributing to Zewo you are contributing to an open and engaged community of brilliant Swift programmers. Join us on [Slack][slack-url] to get to know us!

## License

This project is released under the MIT license. See [LICENSE](LICENSE) for details.

[codebeat-badge]: https://codebeat.co/badges/e6e7bdb7-155e-4d8e-909c-eec6e3c647f4
[codebeat-url]: https://codebeat.co/projects/github-com-zewo-thread
[mit-badge]: https://img.shields.io/badge/License-MIT-blue.svg?style=flat
[mit-url]: https://tldrlegal.com/license/mit-license
[platform-badge]: https://img.shields.io/badge/Platforms-OS%20X%20--%20Linux-lightgray.svg?style=flat
[platform-url]: https://swift.org
[slack-badge]: https://zewo-slackin.herokuapp.com/badge.svg
[slack-image]: http://s13.postimg.org/ybwy92ktf/Slack.png
[slack-url]: http://slack.zewo.io
[swift-badge]: https://img.shields.io/badge/Swift-3.0-orange.svg?style=flat
[swift-url]: https://swift.org
[travis-badge]: https://travis-ci.org/Zewo/Thread.svg?branch=master
[travis-url]: https://travis-ci.org/Zewo/Thread
[zewo-badge]: https://img.shields.io/badge/Zewo-0.7-FF7565.svg?style=flat
[zewo-url]: http://zewo.io
