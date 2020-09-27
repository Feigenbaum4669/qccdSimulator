/* Example of a directed graph with weights */

#include <igraph/igraph.h>
#include <stdarg.h>

void print(igraph_t *g) {
    igraph_vector_t el;
    long int i, j, n;
    char ch = igraph_is_directed(g) ? '>' : '-';

    igraph_vector_init(&el, 0);
    igraph_get_edgelist(g, &el, 0);
    n = igraph_ecount(g);

    for (i = 0, j = 0; i < n; i++, j += 2) {
        printf("%ld --%c %ld: %ld\n",
               (long)VECTOR(el)[j], ch, (long)VECTOR(el)[j + 1], (long)EAN(g, "weight", i));
    }
    printf("\n");

    igraph_vector_destroy(&el);
}

int main() {
    igraph_t g;
    igraph_matrix_t mat;
    int m[6][6] = { { 0, 0, 1, 0, 0, 0 }, { 0, 0, 0, 0, 1, 0 }, { 0, 0, 0, 3, 0, 0 }
                , { 0, 2, 0, 0, 0, 0 }, { 0, 0, 0, 0, 0, 3 }, { 2, 0, 0, 0, 0, 0 }};
    long int i, j;

    igraph_matrix_init(&mat, 6, 6);
    for (i = 0; i < 6; i++) for (j = 0; j < 6; j++) {
            MATRIX(mat, i, j) = m[i][j];
        }
    igraph_i_set_attribute_table(&igraph_cattribute_table);
     /*     0  1  2  3  4  5
      0  [  0  0  1  0  0  0 ]
      1  [  0  0  0  0  1  0 ]
      2  [  0  0  0  3  0  0 ]
      3  [  0  2  0  0  0  0 ] 
      4  [  0  0  0  0  0  3 ]
      5  [  2  0  0  0  0  0 ]   */
    igraph_weighted_adjacency(&g, &mat, IGRAPH_ADJ_DIRECTED, 0, /*loops=*/ 1);
    print(&g);
    igraph_destroy(&g);

    igraph_matrix_destroy(&mat);

    if (IGRAPH_FINALLY_STACK_SIZE() != 0) {
        return 1;
    }

    return 0;
}