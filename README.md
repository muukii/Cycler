---
description: A Store-Pattern based data-flow architecture.
---

# Verge \(v6.0.0-beta.1\)

📖[**Open Documentation on GitBook**](https://muukii-app.gitbook.io/verge/)  
**For viewing on GitHub repo,  
This page has been generated by GitBook.**

 **🖥**[**Open GitHub Repo**](https://github.com/muukii/Verge)\*\*\*\*

{% hint style="warning" %}
The newest Verge \(6.0.0\) is still in development.  
That's why the documentations are not completed and it will be updated.
{% endhint %}

![Data flow](.gitbook/assets/loop-2x.png)

**A Store-Pattern based data-flow architecture.**

The concept of VergeStore is inspired by [Redux](https://redux.js.org/) and [Vuex](https://vuex.vuejs.org/).

The characteristics are

* **Creates one or more Dispatcher. \(Single store, multiple dispatcher\)**
* **A dispatcher can have dependencies service needs. \(e.g. API Client, DB\)**
* **No switch-case to handle Mutation and Action**
* **Supports Logging \(Commit, Action, Performance monitoring\)**

Verge provides several packages each use-cases.

{% page-ref page="vergestore/core-concepts/" %}

{% page-ref page="concepts/core-concepts.md" %}

{% page-ref page="verge-orm/core-concepts.md" %}



