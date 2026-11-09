#!/usr/bin/env python3
"""Render an rclone lsjson listing with terminal icons, colors, and trees."""

import argparse
import json
import os
import sys
from collections import defaultdict
from datetime import datetime
from pathlib import PurePosixPath


# File extension -> Nerd Font icon and ANSI color. Folders use bold blue.
ICONS = {
    ".py": ("", "33"),
    ".pdf": ("", "32"),
    ".tex": ("", "36"),
    ".md": ("", "36"),
    ".txt": ("", "0"),
    ".sh": ("", "0"),
    ".zsh": ("", "0"),
    ".json": ("", "33"),
    ".toml": ("", "35"),
    ".png": ("", "35"),
    ".jpg": ("", "35"),
    ".jpeg": ("", "35"),
    ".mp3": ("", "36"),
    ".flac": ("", "36"),
    ".mp4": ("", "35"),
    ".mkv": ("", "35"),
    ".zip": ("", "31"),
    ".gz": ("", "31"),
}


def safe(text):
    """Keep control characters in filenames from changing terminal output."""
    return "".join(c if c.isprintable() else repr(c)[1:-1] for c in text)


def size(value):
    if value is None or value < 0:
        return "?"
    if value < 1000:
        return str(value)
    for unit in ("k", "M", "G", "T", "P", "E"):
        value /= 1000
        if value < 1000 or unit == "E":
            amount = f"{value:.1f}" if value < 10 else f"{value:.0f}"
            return amount.removesuffix(".0") + unit


def modified(value):
    """Show the remote timestamp in the terminal's local timezone, if available."""
    if not value:
        return "-"
    try:
        timestamp = datetime.fromisoformat(value.replace("Z", "+00:00")).astimezone()
    except (ValueError, OverflowError):
        return "-"
    if timestamp.year <= 1:
        return "-"
    ending = timestamp.strftime("%H:%M" if timestamp.year == datetime.now().year else "%Y")
    return f"{timestamp.day:>2} {timestamp:%b} {ending}"


def amount(item):
    # Directory size is not an aggregate: obtaining it would require extra scans.
    return "-" if item.get("IsDir") else size(item.get("Size"))


def ordered(entries):
    return sorted(
        entries,
        key=lambda item: (not item.get("IsDir"), item["Path"].casefold()),
    )


def render(items, mode, color, show_size=False):
    def paint(text, code):
        return f"\033[{code}m{text}\033[0m" if color else text

    def label(item, text):
        if item.get("IsDir"):
            icon, code = "", "34;1"
            text += "/"
        else:
            suffix = PurePosixPath(item["Path"]).suffix.lower()
            icon, code = ICONS.get(suffix, ("", "0"))
            if PurePosixPath(item["Path"]).name.lower().startswith("readme"):
                icon, code = "", "33;4"
        return paint(f"{icon}  {safe(text)}", code)

    def colored_amount(item, width):
        text = amount(item).rjust(width)
        return paint(text, "32") if amount(item) not in {"-", "?"} else text

    if mode == "long":
        entries = ordered(items)
        width = max([len("Size"), *(len(amount(item)) for item in entries)])
        dates = [modified(item.get("ModTime")) for item in entries]
        date_width = max([len("Date Modified"), *(len(date) for date in dates)])
        print(paint(f"{'Size':>{width}}  {'Date Modified':<{date_width}}  Name", "4"))
        for item, date in zip(entries, dates):
            date_text = date.ljust(date_width)
            if date != "-":
                date_text = paint(date_text, "34")
            name = item["Path"].rpartition("/")[2]
            print(f"{colored_amount(item, width)}  {date_text}  {label(item, name)}")
        if not entries:
            print("(empty)")
        return

    if not items:
        print("(empty)")
        return

    if mode != "tree":
        for item in ordered(items):
            print(label(item, item["Path"]))
        return

    children = defaultdict(list)
    known_dirs = {item["Path"] for item in items if item.get("IsDir")}
    needed_dirs = set()
    for item in items:
        parent = item["Path"].rpartition("/")[0]
        children[parent].append(item)
        while parent:
            needed_dirs.add(parent)
            parent = parent.rpartition("/")[0]

    # Filters can omit a parent directory while retaining files below it.
    for directory in needed_dirs - known_dirs:
        parent = directory.rpartition("/")[0]
        children[parent].append({"Path": directory, "IsDir": True})

    width = max([len("Size"), *(len(amount(item)) for item in items)])

    def walk(parent="", prefix=""):
        entries = ordered(children[parent])
        for index, item in enumerate(entries):
            last = index == len(entries) - 1
            branch = "└── " if last else "├── "
            name = item["Path"].rpartition("/")[2]
            line = prefix + branch + label(item, name)
            if show_size:
                line = colored_amount(item, width) + "  " + line
            print(line)
            if item.get("IsDir"):
                continuation = "    " if last else "│   "
                walk(item["Path"], prefix + continuation)

    if show_size:
        print(paint(f"{'Size':>{width}}  Name", "4"))
        print(" " * width + "  .")
    else:
        print(".")
    walk()


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("mode", choices=("list", "dirs", "long", "tree"))
    parser.add_argument("--size", action="store_true", help="include a size column in trees")
    args = parser.parse_args()
    try:
        items = json.load(sys.stdin)
    except json.JSONDecodeError:
        sys.exit("rclone formatter: could not read a complete JSON listing.")
    if items is None:
        items = []
    if not isinstance(items, list):
        sys.exit("rclone formatter: expected a listing; do not use --stat.")

    color = (
        sys.stdout.isatty()
        and "NO_COLOR" not in os.environ
        and os.environ.get("TERM") != "dumb"
    )
    render(items, args.mode, color, args.size)


if __name__ == "__main__":
    try:
        main()
    except BrokenPipeError:
        # Avoid a traceback when a consumer such as head closes the pipe early.
        sys.exit(0)
