/* -*- coding: utf-8 -*-
 * ----------------------------------------------------------------------
 * Copyright © 2012, libcork authors
 * All rights reserved.
 *
 * Please see the COPYING file in this distribution for license details.
 * ----------------------------------------------------------------------
 */

#include <getopt.h>
#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <libcork/core.h>

enum cork_hash_type {
    CORK_HASH_BIG,
    CORK_HASH_FASTEST,
    CORK_HASH_STABLE
};

static enum cork_hash_type  type = CORK_HASH_STABLE;
static const char  *string = NULL;

#define OPT_VERSION 1000

static void
usage(void)
{
    fprintf(stderr,
            "Usage: cork-hash [<options>] <string>\n"
            "\n"
            "Options:\n"
            "  -b, --big\n"
            "  -f, --fastest\n"
            "  -s, --stable\n");
}

static void
print_version(void)
{
    const char  *version = cork_version_string();
    const char  *revision = cork_revision_string();

    printf("cork-hash %s\n", version);
    if (strcmp(version, revision) != 0) {
        printf("Revision %s\n", revision);
    }
}

static void
parse_options(int argc, char **argv)
{
    int  ch;
    while ((ch = getopt(argc, argv, "bfs")) != -1) {
        switch (ch) {
            case 'b':
                type = CORK_HASH_BIG;
                break;
            case 'f':
                type = CORK_HASH_FASTEST;
                break;
            case 's':
                type = CORK_HASH_STABLE;
                break;
                exit(EXIT_SUCCESS);
            default:
                usage();
                exit(EXIT_FAILURE);
        }
    }

    if (optind != argc-1) {
        usage();
        exit(EXIT_FAILURE);
    }

    string = argv[optind];
}

int
main(int argc, char **argv)
{
    parse_options(argc, argv);

    if (type == CORK_HASH_BIG) {
        cork_big_hash  result = CORK_BIG_HASH_INIT();
        result = cork_big_hash_buffer(result, string, strlen(string));
        printf("%016" PRIx64 "%016" PRIx64 "\n",
               cork_u128_be64(result.u128, 0),
               cork_u128_be64(result.u128, 1));
    }

    if (type == CORK_HASH_FASTEST) {
        /* don't include NUL terminator in hash */
        cork_hash  result = 0;
        result = cork_hash_buffer(result, string, strlen(string));
        printf("0x%08" PRIx32 "\n", result);
    }

    if (type == CORK_HASH_STABLE) {
        /* don't include NUL terminator in hash */
        cork_hash  result = 0;
        result = cork_stable_hash_buffer(result, string, strlen(string));
        printf("0x%08" PRIx32 "\n", result);
    }

    return EXIT_SUCCESS;
}
