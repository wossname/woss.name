---
published_on: 2012-04-02
title: Retrieving BigDecimals from a database with Anorm & Scala
excerpt: In which I take a long, long time just to retrieve a couple of numbers from
  a DB and display them on a web page. Ah, the joys of learning a new programming
  language, framework and ecosystem, all at once!
redirect_from: "/2012/04/02/retrieving-bigdecimals-from-a-database-with-anorm-scala/"
category: Programming
tags:
  - scala
  - anorm
  - bigdecimal
  - postgresql
---
I spent a wee while yesterday kicking the tyres on the [Play 2.0](http://www.playframework.org/)
framework with Scala. Aside: I think that concurrency/asynchronous processing
is *really* important in the age of multi-core CPUs, and that
[Akka's](http://akka.io/) actor-based system is *really* interesting, and Play
uses Akka 2 under the hood, so I'm becoming *really* interested in becoming
proficient in Scala & Play 2. That said, so far I'm struggling to come to terms
with Scala's type system, and it reminds of the struggles I had with ML at
University, so this could be an uphill battle!

Anyway, that's not what this is about. The toy application I'm trying to build
(which I'll share if and when I'm done!) involves storing locations (a latitude
and longitude) as decimals. I've got my table (stored as an evolution) along
the lines of:

```sql
CREATE TABLE sites (
  id SERIAL PRIMARY KEY,
  name VARCHAR(255) UNIQUE NOT NULL,
  latitude NUMERIC NOT NULL,
  longitude NUMERIC NOT NULL,
  UNIQUE(latitude, longitude)
);
```

(I'm using PostgreSQL.) And here's the first implementation of the model,
`app/models/Site.scala`, which just has a `case class` to encapsulate the table
data, and a singleton object with a finder to return a sequence of site (so
that I can list them in a table):

```scala
package models
import play.api.db._
import play.api.Play.current
import anorm._
import anorm.SqlParser._

case class Site(
  id: Pk[Long],
  name: String,
  latitude: BigDecimal,
  longitude: BigDecimal
)

object Site {
  val allFieldsParser = {
    get[Pk[Long]]("sites.id") ~
    get[String]("sites.name") ~
    get[BigDecimal]("sites.latitude") ~
    get[BigDecimal]("sites.longitude") map {
      case id ~ name ~ latitude ~ longitude =>
        Site(id, name, latitude, longitude)
    }
  }

  def findAll(): Seq[Site] = {
    DB.withConnection { implicit connection =>
      SQL("SELECT * FROM sites").as(Site.allFieldsParser *)
    }
  }
}
```

(Totally cargo-culted, BTW.) This means that in the controller I should be able
to call `Site.findAll()` and get back a sequence of sites I can then use to map
to HTML fragments. Win.

But I'm getting a compilation error! In the browser, it's saying `could not
find implicit value for parameter extractor: anorm.Column[BigDecimal]` and
pointing to the error being on `get(BigDecimal)("sites.latitude")` in the
parser.

I couldn't find any documentation on retrieving decimals from a database with
anorm (which is mostly why I'm writing this) and looking through the source
code didn't exactly elucidate. However, after a bit of trial and error, I
discovered that it works if I add:

```scala
import java.math.BigDecimal
```

at the start of the model file.

So, if you're having trouble making `BigDecimal` columns work in your
Anorm-based models, remember to explicitly `import java.math.BigDecimal`.
Hopefully this will find its way into Google, making the next Scala newbie's
introduction a little less painful. :)

I'd love if somebody could explain why. Perhaps it would improve my
understanding of Scala!

**Update** Aha, I have a theory. I think that, by default,
[`scala.math.BigDecimal`](http://www.scala-lang.org/api/current/index.html#scala.math.BigDecimal)
is available in my model's scope. And `scala.math.BigDecimal` isn't a subtype
of `java.math.BigDecimal`, which is what Anorm deals in. So importing the Java
version overrides the Scala version and makes the type system happy.

Now I'm wondering: why the two unrelated (in type-land anyway) versions of
`BigDecimal`? Which should my apps be using? Which should Anorm be exposing?
