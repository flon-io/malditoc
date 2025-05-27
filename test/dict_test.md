
# dict_test.md

setup
```c
  #include "flutil.h"
```

## flu_list as dict

before
```c
  flu_list *l = flu_list_malloc();
```

after
```c
  flu_list_free(l);
```

### flu_list_set()

#### sets a node with a key at the beginning of the list

```c
  flu_list_set(l, "red", "aka");

  assert(l->size == 1);
  assert(l->first->key === "red");
  assert(l->first->item === "aka");

  flu_list_set(l, "red", "rodzo");

  assert(l->size == 2);
  assert(l->first->key === "red");
  assert(l->first->item === "rodzo");
```

### flu_readdict()

before
```c
  flu_dict *d = NULL;
```
after
```c
  flu_list_free_all(d);
```

#### returns NULL when the path points to something unreadable

```c
  expect(flu_readdict("tmp/_nada") == NULL);
```

#### reads a dict

```c

  d = flu_readdict("../spec/%s", "dict0.txt");

  expect(d != NULL);
  expect(d->size zu== 4);
  expect(flu_list_get(d, "color") === "blue");
  expect(flu_list_get(d, "age") === "3 years");
  expect(flu_list_get(d, "location") === "beach");
  expect(flu_list_get(d, "price") === "1 dollar");
```

OVER.


```c
//
// specifying flutil
//
// Fri Sep  5 06:21:05 JST 2014
//

#include "flutil.h"


context "flu_list as dict"
{
  before each
  {
    flu_list *l = flu_list_malloc();
  }
  after each
  {
    flu_list_free(l);
  }

  describe "flu_list_set()"
  {
    it "sets a node with a key at the beginning of the list"
    {
      flu_list_set(l, "red", "aka");

      ensure(l->size == 1);
      ensure(l->first->key === "red");
      ensure(l->first->item === "aka");

      flu_list_set(l, "red", "rodzo");

      ensure(l->size == 2);
      ensure(l->first->key === "red");
      ensure(l->first->item === "rodzo");
    }

    it "composes its key"
    {
      flu_list_set(l, "red-%s", "car", "ferrari");
      flu_list_set(l, "blue-%s", "plane", "corsair");

      expect(flu_list_to_s(l) ===f "{blue-plane:corsair,red-car:ferrari}");
    }
  }

  describe "flu_list_setk()"
  {
    it "sets a node, without duplicating the key string"
    {
      flu_list_setk(l, strdup("red"), "aka", 0);

      expect(1 == 1);

      // segfaults or leaks when _setk() is not right
    }

    it "sets as last"
    {
      flu_list_setk(l, strdup("red"), "aka", 0);
      flu_list_setk(l, strdup("green"), "aoi", 1);

      expect(l->first->key === "red");
      expect(l->last->key === "green");
    }
  }

  describe "flu_list_set_last()"
  {
    it "sets a 'default'"
    {
      flu_list_set(l, "red", "aka");
      flu_list_set_last(l, "red", "murakami");

      ensure(l->size == 2);
      ensure(flu_list_get(l, "red") === "aka");
    }

    it "composes its key"
    {
      flu_list_set(l, "r%s", "ed", "aka");
      flu_list_set_last(l, "re%c", 'd', "murakami");

      ensure(l->size == 2);
      ensure(flu_list_get(l, "red") === "aka");
    }
  }

  describe "flu_list_sets()"
  {
    it "composes key and string value"
    {
      flu_list_sets(l, "r%s", "ed", "a%s", "ka");
      flu_list_sets(l, "re%c", 'd', "mura%cami", 'k');

      expect(flu_list_to_s(l) ===f "{red:murakami,red:aka}");

      flu_list_free_all(l); l = NULL;
    }
  }

  describe "flu_list_get()"
  {
    it "returns NULL if there is no item for the key"
    {
      ensure(flu_list_get(l, "red") == NULL);

      flu_list_set(l, "red", "rot");
      flu_list_set(l, "red", NULL);

      ensure(flu_list_get(l, "red") == NULL);

      flu_list_set(l, "red", "rouge");

      ensure(flu_list_get(l, "red") === "rouge");
    }

    it "returns the item for the first node with the given key"
    {
      flu_list_set(l, "red", "rot");

      ensure(flu_list_get(l, "red") === "rot");

      flu_list_set(l, "red", "rouge");

      ensure(flu_list_get(l, "red") === "rouge");
    }

    it "skips non-keyed nodes"
    {
      flu_list_set(l, "blue", "bleu");
      flu_list_unshift(l, "black");

      ensure(flu_list_get(l, "blue") === "bleu");
    }

    it "composes its key"
    {
      flu_list_set(l, "light%s", "grey", "gris souris");

      ensure(flu_list_get(l, "light%s", "grey") === "gris souris");
    }
  }

  describe "flu_list_getd()"
  {
    it "returns the value in case of hit"
    {
      flu_list_set(l, "purple", "murasaki");

      ensure(flu_list_getd(l, "purple", "*nada*") === "murasaki");
    }

    it "returns the default value in case of miss"
    {
      ensure(flu_list_getd(l, "red", "ruddyraga") === "ruddyraga");
    }

    it "composes its key"
    {
      flu_list_set(l, "purple", "murasaki");

      ensure(flu_list_getd(l, "p%crple", 'u', "*nada*") === "murasaki");
      ensure(flu_list_getd(l, "red%i", 1, "ruddyraga") === "ruddyraga");
    }
  }

  describe "flu_list_getod()"
  {
    it "returns the value in case of hit"
    {
      flu_list_set(l, "purple", "murasaki");

      ensure(flu_list_getod(l, "purple", "*nada*") === "murasaki");
    }

    it "returns the default value in case of miss"
    {
      ensure(flu_list_getod(l, "red", "ruddyraga") === "ruddyraga");
    }

    it "returns the default if the dict is NULL"
    {
      ensure(flu_list_getod(NULL, "red", "rouge") === "rouge");
    }
  }

  describe "flu_list_dtrim()"
  {
    it "returns a new, trimmed, flu_list"
    {
      flu_list_set(l, "red", "aka");
      flu_list_set(l, "blue", "ao");

      flu_list *tl = flu_list_dtrim(l);

      ensure(tl->size == 2);
      ensure(flu_list_at(tl, 0) === "ao");
      ensure(flu_list_at(tl, 1) === "aka");
      ensure(tl->first->key === "blue");
      ensure(tl->last->key === "red");

      flu_list_free(tl);
    }

    it "returns a new, trimmed, flu_list (2)"
    {
      flu_list_set(l, "blue", "bleu");
      flu_list_unshift(l, "black");
      flu_list_set(l, "white", "blanc");
      flu_list_set(l, "blue", "blau");
      flu_list_set(l, "white", NULL);
      flu_list_set(l, "red", "rojo");

      flu_list *tl = flu_list_dtrim(l);

      //size_t i = 0;
      //for (flu_node *n = tl->first; n != NULL; n = n->next)
      //{
      //  printf("%zu: %s: \"%s\"\n", i++, n->key, (char *)n->item);
      //}

      ensure(tl->size == 3);
      ensure(flu_list_at(tl, 0) === "rojo");
      ensure(flu_list_at(tl, 1) === NULL);
      ensure(flu_list_at(tl, 2) === "blau");
      ensure(tl->first->key === "red");
      ensure(tl->last->key === "blue");

      flu_list_free(tl);
    }
  }

  describe "flu_d()"
  {
    before each
    {
      flu_list *d = NULL;
    }
    after each
    {
      flu_list_free(d);
    }

    it "builds a flu_list dict"
    {
      d = flu_d("name", "Hans", "age", "30", "balance", "1000", NULL);

      expect(d->size == 3);
      expect(flu_list_get(d, "name") === "Hans");
      expect(flu_list_get(d, "age") === "30");
      expect(flu_list_get(d, "balance") === "1000");
    }

    it "accepts NULL as a value"
    {
      d = flu_d("k0", NULL, NULL);

      expect(d->size == 1);
      expect(flu_list_get(d, "k0") == NULL);
    }

    it "accepts NULL as a value (2)"
    {
      d = flu_d("k0", NULL, "k1", NULL, NULL);

      expect(d->size == 2);
      expect(flu_list_get(d, "k0") == NULL);
      expect(flu_list_get(d, "k1") == NULL);
    }
  }

  describe "flu_sd()"
  {
    before each
    {
      flu_list *d = NULL;
    }
    after each
    {
      flu_list_free_all(d);
    }

    it "composes string -> string dictionaries"
    {
      d =
        flu_sd(
          "name", "Hans %s", "Rothenmeyer",
          "age", "%X", 15 + 1 + 11,
          "balance", "10%s", "05",
          "x_%s", "special", "nothing",
          NULL);

      expect(d->size zu== 4);
      expect(flu_list_get(d, "name") === "Hans Rothenmeyer");
      expect(flu_list_get(d, "age") === "1B");
      expect(flu_list_get(d, "balance") === "1005");
      expect(flu_list_get(d, "x_special") === "nothing");

      //flu_list_free_all(d);
        //
        // Contrast with flu_d() above. Here, all the strings are
        // malloc'ed so _free_all is "de rigueur".
    }

    it "accepts NULL as a value"
    {
      d = flu_sd("k0", NULL, NULL);

      expect(d != NULL);
      expect(d->size == 1);
      expect(flu_list_get(d, "k0") == NULL);
    }
  }

  describe "flu_list_concat()"
  {
    before each
    {
      flu_dict *d0 = NULL;
      flu_dict *d1 = NULL;
    }
    after each
    {
      flu_list_free(d0);
      flu_list_free(d1);
    }

    it "adds (to, from)"
    {
      d0 = flu_d("arnold", "etwilly", NULL);
      d1 = flu_d("bob", "morane", NULL);

      flu_list_concat(d0, d1);

      expect(flu_list_to_s(d0) ===f "{arnold:etwilly,bob:morane}");
      expect(flu_list_to_s(d1) ===f "{bob:morane}");

      expect(flu_list_to_sm(d0) ===f "{\n  arnold: etwilly,\n  bob: morane\n}");
      expect(flu_list_to_sm(d1) ===f "{\n  bob: morane\n}");

      //flu_putf(flu_list_to_s(d0));
      //flu_putf(flu_list_to_s(d1));
      //flu_putf(flu_list_to_sp(d0));
      //flu_putf(flu_list_to_sp(d1));
    }
  }

  describe "flu_list_to_s()"
  {
    it "doesn't mind a NULL item"
    {
      flu_list_set(l, "a", "Andre");
      flu_list_set(l, "b", NULL);
      flu_list_set(l, "c", "Charles");

      expect(flu_list_to_s(l) ===f "{c:Charles,b:NULL,a:Andre}");
    }
  }

  describe "flu_readdict()"
  {
    before each
    {
      flu_dict *d = NULL;
    }
    after each
    {
      flu_list_free_all(d);
    }

    it "returns NULL when the path points to something unreadable"
    {
      expect(flu_readdict("tmp/_nada") == NULL);
    }

    it "reads a dict"
    {
      d = flu_readdict("../spec/%s", "dict0.txt");

      expect(d != NULL);
      expect(d->size zu== 4);
      expect(flu_list_get(d, "color") === "blue");
      expect(flu_list_get(d, "age") === "3 years");
      expect(flu_list_get(d, "location") === "beach");
      expect(flu_list_get(d, "price") === "1 dollar");
    }
  }
}
```

