# LuaMeta
A collection of metaprogramming examples for Lua

Table of Contents
=================
* [Class](#class)
    * [How to use](#how-to-use)
        * [Declaration](#declaration)
        * [Constructors](#constructors)
        * [Static methods](#static-methods)
        * [Object methods](#object-methods)
        * [Metamethods](#metamethods)
        * [Inheritance](#inheritance)
* [Trait](#trait)
    * [How to use](#how-to-use-1)
        * [Declaration](#declaration-1)
        * [Methods](#methods)
        * [Implementation](#implementation)
* [Namespace](#namespace)
    * [How to use](#how-to-use-2)
        * [Declaration](#declaration-2)
        * [Classes](#classes)
        * [Traits](#traits)
        * [Nested namespaces](#nested-namespaces)
        * [Include](#include)
* [Perks](#perks)
* [Future Meta](#future-meta)

# Class
Generic class from OOP languages.
## How to use
### Declaration
Declaring an empty class. 

Take note that classes are declared globally. Classes fail to declare if there is already a global variable that occupies the name.

```lua
local class = require "luameta.src.class"
class "test"
```
[Back to top](#luameta)
### Constructors
You know what a constructor is.
LuaMeta constructors occupies the first parameter for the created object instance.
The difference of constructors with static and object methods is that they accept functions not table of functions.

```lua
class "test"
    : constructor (function (self, intro)
        self.intro = intro
    end)

local example = test("hello, this is an intro")
print(example.intro)
```

You can declare multiple constructors, but they do not redeclare it, they act as one when the constructor is called. But, be careful, if you happen to declare multiple constructors, they should have similar parameters.
```lua
class "test"
    : constructor (function (self, intro, closure)
        self.intro = intro
    end)
    : constructor (function (self, intro, closure)
        self.closure = closure
    end)

local example = test("this is an intro", "this is a closure")
print(example.intro)
print(example.closure)
```
[Back to top](#luameta)
### Static methods
Static methods are methods that do not require object instances.
```lua
class "test"
    : static {
        say = function (...)
            print(...)
        end
    }

-- access the static method
test.say("hello world") -- prints "hello world" 
```
Multiple static methods are simply declaring multiple keyed functions inside a table.
```lua
class "test"
    : static {
        say = function (...)
            print(...)
        end,
        add = function (a, b)
            return a + b
        end
    }

    --you can also do this, for the convenience of grouping methods
    : static {
        sub = function (a, b)
            return a - b
        end
    }
```
[Back to top](#luameta)
### Object methods
Object methods, unlike statics, require object instances.
In LuaMeta, each "method"'s first parameter is occupied for the object instance
```lua
class "test"
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end
    }

local example = test()
example:setMessage("this is a test")
print(example.msg) -- prints "this is a test"
```

Multiple object methods 
```lua
class "test"
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end,
        repeatMessage = function (self, n)
            self.msg = string.rep(self.msg, n)
        end
    }
    -- same with statics
    : method {
        empty = function (self)
            self.msg = ""
        end
    }
```
[Back to top](#luameta)
### Metamethods
To declare a metamethod
```lua
class "test"
    : meta {
        __tostring = function (a)
            return "hohoho "..a
        end
    }
```
You cannot redeclare the metamethods "__newindex" and "__index".

Here is an example of a super-mini vector class
```lua
class "vector"
    : constructor(function (self, x, y)
        self.x = x
        self.y = y
    end)
    : meta {
        __add = function (a, b)
            return vector(a.x + b.x, a.y + b.y)
        end,
        __eq = function (a, b)
            return a.x == b.x and a.y == b.y 
        end,
        __tostring = function (a)
            return "vector("..a.x..", "..a.y..")"
        end
    }

local vectorA = vector(1, 1)
local vectorB = vector(2, 2)
print(vectorA + vectorB)
print(vectorA == vectorB)
```

[Back to top](#luameta)

### Inheritance
To perform class inheritance:
```lua
class "child" : extends "parent"
```
A class can only inherit a parent once.
```lua

class "test"
    : static {
        say = function (msg)
            print(msg)
        end 
    }
    : method {
        speak = function (self, msg)
            print(self.intro, msg)
        end
    }
    : constructor ( function (self, intro)
        self.intro = intro or "hello, the message is"
    end)

class "test2" : extends "test"
```

Subclasses can override parent static methods. You can still access original parent method by using the super reference:
```lua
class "test2" : extends "test"
    : static {
        say = function (msg)
            print("the message is: ", msg)
        end
    }

test2.say("hello")          -- "the message is:     hello"

test2.super.say("hello")    -- "hello"
```

Child class instances can also access the original parent object method by creating a super instance of itself.
```lua
class "vec2"
    : constructor (function (self, x, y)
        self.x = x or 0
        self.y = y or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec2("..self.x..", "..self.y..")"
        end
    }

class "vec3" : extends "vec2"
    : constructor (function (self, x, y, z)
        self.z = z or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec3("..self.x..", "..self.y..", "..self.z..")"
        end
    }

class "vec4" : extends "vec3"
    : constructor (function (self, x, y, z, w)
        self.w = w or 0
    end)
    : meta {
        __tostring = function (self)
            return "vec4("..self.x..", "..self.y..", "..self.z..", "..self.w..")"
        end
    }

local a = vec2(1, 2)
local b = vec3(1, 2, 3)
local c = vec4(1, 2, 3, 4)

print(a)                    -- vec2(1, 2)
print(b)                    -- vec3(1, 2, 3)
print(c)                    -- vec4(1, 2, 3, 4)
print(b:super())            -- vec2(1, 2)
print(c:super())            -- vec3(1, 2, 3)
print(c:super():super())    -- vec4(1, 2, 3, 4)
```
Take note that using :super() will create a separate instance. It is not actually a class cast, it is more of a super class clone of the child instance. 

Every :super() call is a different instance. 

Modifying :super() instances will not modify the child instance.

[Back to top](#luameta)
# Traits
Traits are structures that can be implemented in classes. They are, somewhat, pieces of an empty class that can be appended to other classes.

[Back to top](#luameta)
## How to use
### Declaration
Similar behavior with the classes, they are declared globally.

```lua
local trait = require "luameta.src.trait"

trait "exampleTrait"
```

[Back to top](#luameta)
### Methods
Similar to how you declare static methods and object methods in classes

```lua
trait "exampleTrait"
    : static {
        say = function (msg)
            print(msg)
        end
    }
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end
    }
```

[Back to top](#luameta)
### Implementation
To implement a trait into a class:
``` lua
trait "exampleTrait"
    : static {
        say = function (msg)
            print(msg)
        end
    }
    : method {
        setMessage = function (self, msg)
            self.msg = msg
        end,
        say = function (self)
            print(self.msg)
        end
    }

class "test"
    : implements "exampleTrait"

local example = test()
test.say()
example:setMessage("hello")
example:say()
```

Traits can also implement other traits!
```lua
trait "exampleTraitStatic"
    : static {
        say = function (...)
            print(...)
        end
    }

trait "exampleTraitMethod"
    : method {
        say = function (self)
            print(self.intro .. " " .. self.msg)
        end,
        setMessage = function (self, msg)
            self.msg = msg
        end
    }

trait "exampleTrait"
    : implements "exampleTraitStatic"
    : implements "exampleTraitMethod"

class "test" 
    : constructor (function (self, intro)
        self.msg = "default string"
        self.intro = intro
    end)
    : implements "exampleTrait"
    : method {
        repeatMessage = function (self, n)
            self.msg = string.rep(self.msg, n)
        end
    }
    : meta {
        __tostring = function (self)
            return self.msg
        end
    }

local a = test("Hello, the message is")
test.say("this is a test")
a:say()
a:setMessage("hello world")
a:say()
a:repeatMessage(2)
a:say()
```

[Back to top](#luameta)
# Namespace
Namespaces are structures that keeps the other metastructures declared in scopes(I should've named it "scope", but anyways, you can name it whatever you want.). 

Classes, Traits, etc. declared inside Namespaces are not declared in the global spaces. 

If ever, you declared them outside the namespace and decided to put the global reference inside the namespace, they lose their global reference thereafter.

[Back to top](#luameta)
## How to use
### Declaration
```lua
local namespace = require "luameta.src.namespace"

namespace "example"
```
[Back to top](#luameta)
### Classes
Classes are declared the same way as it is globally

```lua
namespace "example" {
    class "test" 
        : static {
            say = function (...)
                print(...)
            end
        }
}
```

If you want to access it:
```lua
example.test.say("hello, world!")
```

[Back to top](#luameta)
### Traits
Same way as normal Traits
```lua
namespace "example" {
    trait "exampleTrait"
        : static {
            say = function (...)
                print(...)
            end
        }
}
```

Now, if ever a class declared inside a namespace implements another trait (inside or outside the namespace),it searches for similarly named traits from its namespace siblings.
```lua
namespace "example" {
    trait "exampleTrait" 
        : static {
            say = function (msg)
                print("the message is :", msg)
            end
        }
    ,
    class "test"
        : implements "exampleTrait"
}

trait "exampleTrait"
    : static {
        say = function (...)
            print(...)
        end 
    }

class "test"
    : implements "exampleTrait"

example.test.say("hello, world")    -- "the message is: hello, world"
test.say("hello", "world")          -- hello     world
```

[Back to top](#luameta)
### Nested namespaces
Yep, it is a feature

```lua
namespace "example2" {
    trait "vectorMeta"
        : meta {
            __add = function (a, b)
                return example2.example3.vector(a.x + b.x, a.y + b.y)
            end,
            __tostring = function (a)
                return "vector("..a.x..", "..a.y..")"
            end
        }
    ,
    namespace "example3" {
        class "vector"
            : constructor (function (self, x, y)
                self.x = x 
                self.y = y
            end)
            : implements "vectorMeta"
    }
}

local ex = example2.example3

local a = ex.vector(1, 2)
local b = ex.vector(2, 3)

print(a + b)    -- vector(3, 5)
```

[Back to top](#luameta)
### Include
In case you want to separate your code for namespaces, you can use include
```lua 
namespace "example2" {
    trait "vectorMeta"
        : meta {
            __add = function (a, b)
                return example2.example3.vector(a.x + b.x, a.y + b.y)
            end,
            __tostring = function (a)
                return "vector("..a.x..", "..a.y..")"
            end
        }
    ,
    namespace "example3" {
        class "vector"
            : constructor (function (self, x, y)
                self.x = x 
                self.y = y
            end)
            : implements "vectorMeta"
    }
} : include {
    namespace "example4" {
        class "vec3"
            : constructor (function (self, x, y, z)
                self.x = x
                self.y = y
                self.z = z
            end)
    }
}
```

Take note that trait implementations will not work if they are separated by include and if string is the argument provided for "implements", since the namespace for the trait is yet unknown during runtime, the workaround is to use the global reference rather than using strings.

```lua
namespace "example" {
    trait "staticSay"
        : static {
            say = function (...)
                print(...)
            end
        }
} : include {
    class "test" 
        : implements (example.staticSay)
}

example.test.say("hello", "world")
```

[Back to top](#luameta)
# Perks
Since these meta features are loaded by modules, you can use alternative keywords (that aren't reserved by Lua, obviously)! But not for the member features, of course.

```lua
local object = require "luameta.src.class"

object "test"
    : static {
        say = function (...)
            print(...)
        end
    }
```

[Back to top](#luameta)
# Future Meta
These features will be added soon:
- Switch
- Pattern Matching

and others. I will be looking for other structures from other languages and try to implement them here!

[Back to top](#luameta)