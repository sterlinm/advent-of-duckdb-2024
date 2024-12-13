# Problem Description

[Day 5](https://adventofcode.com/2024/day/5)

> The Elf has for you both the page ordering rules and the pages to produce in each update (your puzzle input), but can't figure out whether each update has the pages in the right order.



- Read in input as a one-column varchar table
- split into a table for the rules and a table for the updates
- group the rules 

## Tables to create

### Input Tables

page_ordering_rule is a table with one row for each potential page, and a list of all pages that must be printed after that page number

page_ordering_rules:
    - page_number (INT)
    - later_pages (INT[])

manual_updates:
    - update_number (INT)
    - update_page_index (INT)
    - update_page_number (INT)