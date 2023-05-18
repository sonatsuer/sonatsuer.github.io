---
title: Optics in Clojure
---

## Dead Simple Optics

Recently I gave a talk about optics in our local *Funktionaler Stammtisch*
--[here](assets/optics-talk.pdf) are the slides if you are curious. My goal
was to help people construct a mental model of optics using their existential
encodings. The language I chose was Kotlin because there were Kotlin programmers in
the audience and there is a nice functional programming library called Arrow
in Kotlin which [implements](https://arrow-kt.io/learn/immutable-data/) optics.

While preparing the talk I had a chance to look at the Kotlin implementation.
In the Arrow library, optics are defined as interfaces. Capabilities of an
optic --things like view, review, traverse, etc-- corresponds to methods of
the interface. If a capability is shared by different optics, this is handled
by inheritance. For instance since isomorphisms can do everything other optics
can do, their interface inherits from all of them. This is from the Arrow library
documentation:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.kotlin}
interface PIso<S, T, A, B> : PPrism<S, T, A, B> , PLens<S, T, A, B> ,
  Getter<S, A> , POptional<S, T, A, B> , PSetter<S, T, A, B> , Fold<S, A> ,
  PTraversal<S, T, A, B> , PEvery<S, T, A, B>
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Behind this OOP noise, there is actually a simple idea: An optic is a collection
of capabilities. Compared to some Haskell implementations, where you talk about
profunctors, existential types or van Laarhoven encodings this is dead simple.

So let's try to imitate this in Haskell. I will focus on isomorphisms,
lenses, prisms and traversals.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data OpticType = Iso | Lens | Prism | Traversal
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

As a very unidiomatic Haskell definition, each capability corresponds
to a field in a record:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
data Optic s t a b = Optic
  { getView :: Maybe (s -> a)
  , getReview :: Maybe (b -> t)
  , getOver :: (a -> b) -> s -> t
  , getToList :: s -> [a]
  , getTraverse :: forall f. Applicative f => (a -> f b) -> (s -> f t)
  }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Now you can recover the type of an optic just by looking at whether
you have `view` and/or `review`.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
classify :: Optic s t a b -> OpticType
classify optic =
  case (getView optic, getReview optic) of
    (Nothing, Nothing) -> Traversal
    (Just _, Nothing) -> Lens
    (Nothing, Just _) -> Prism
    (Just _, Just _) -> Iso
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Obviously this implementation is unusable. Though, I think, if you keep track of
the available capabilities at type level, then you may turn this idea into
a semi-decent optics library.

Even though this record base implementation is not practical, it has a
pedagogical merit: it makes composition explicit.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.haskell}
composeOptics :: Optic s t a' b' -> Optic a' b' a b -> Optic s t a b
composeOptics optic1 optic2 = Optic {
  getView = liftA2 (flip (.)) (getView optic1) (getView optic2),
  getReview = liftA2 (.) (getReview optic1) (getReview optic2),
  getOver = getOver optic1 . getOver optic2,
  getToList = getToList optic1 >=> getToList optic2,
  getTraverse = getTraverse optic1 . getTraverse optic2
  }
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

So composition of optics is just capability wise composition where capabilities compose
in appropriate categories: `view` in the opposite category, `toList` in the Kleisli
category for lists and the rest in the ambient category --Hask if you will.

## Implementation in Clojure

In clojure, where there are no types, you can replace the record above by a good old fashioned
map. Here is what composition looks like in Clojure.

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.clojure}
(defn- compose-binary
  [optic1 optic2]
  (let
   [compose-capability (fn [field-name binary-op] (binary-op (field-name optic1) (field-name optic2)))
    candidates {:view (compose-capability :view backward-compose)
                :to-list (compose-capability :to-list vector-kleisli)
                :over (compose-capability :over forward-compose)
                :review (compose-capability :review forward-compose)
                :traverse (compose-capability :traverse forward-compose)}]
    (into {} (filter (comp some? val) candidates))))

(defn compose
  "General optic composition. Accepts an arbitrary list of
   optics. It produces the `eq`, the unit on optic composition,
   for the empty list."
  ([& optics] (reduce compose-binary eq optics)))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

Actually, one can even build a small library around this idea and that is
exactly what I did. Here it is:
[concrete-optics](https://github.com/sonatsuer/concrete-optics), a dead
simple implementation of optics in Clojure. [Here](https://sonatsuer.github.io/concrete-optics/index.html) is a link to the API docs.

With this library, you can do stuff like this:

~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~ {.clojure}
(def nested-data
  [{:a 1 :b 2} {:c 3} {:a -5} {:a 7 :z 22}])

(def each-positive-a
  (opt/compose opt/vector-traversal
               (opt/ix :a)
               (opt/predicate-prism #(> % 0))))

(deftest list-positive-as-test
  (testing "listing elements with a filtering condition"
    (is (= (opt/to-list each-positive-a nested-data)
           [1 7]))))

(deftest modify-positive-as-test
  (testing "modifying only the values fitting a filtering condition"
    (is (= (opt/over each-positive-a inc nested-data)
           [{:a 2, :b 2} {:c 3} {:a -5} {:a 8, :z 22}]))))
~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

For more examples you can have a look at the [showcase](https://sonatsuer.github.io/concrete-optics/showcase.html). Feedback is most welcome.
