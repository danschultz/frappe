part of frappe.transformers;

typedef R Combiner<A, B, R>(A a, B b);
typedef Stream<T> StreamConverter<S, T>(S event);