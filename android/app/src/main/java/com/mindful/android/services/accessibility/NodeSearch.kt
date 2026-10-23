package com.mindful.android.services.accessibility

import android.view.accessibility.AccessibilityNodeInfo

/**
 * Returns the first visible node in this subtree matching [predicate], or null.
 * Walks via getChild because findAccessibilityNodeInfosByText finds nothing on Facebook's tree.
 */
// ponytail: node cap bounds cost; per-app subtree targeting if profiling shows lag.
internal fun AccessibilityNodeInfo.findVisibleNode(
    maxNodes: Int = 3000,
    predicate: (AccessibilityNodeInfo) -> Boolean,
): AccessibilityNodeInfo? {
    val queue = ArrayDeque<AccessibilityNodeInfo>()
    queue.add(this)
    var visited = 0
    while (queue.isNotEmpty() && visited < maxNodes) {
        val n = queue.removeFirst()
        visited++
        if (!n.isVisibleToUser) continue
        if (predicate(n)) return n
        for (i in 0 until n.childCount) n.getChild(i)?.let(queue::add)
    }
    return null
}

/** Visible selected node whose content description starts with any of [prefixes]. */
internal fun AccessibilityNodeInfo.findSelectedDescPrefix(prefixes: List<String>) =
    findVisibleNode { n ->
        n.isSelected && n.contentDescription?.toString()?.let { d -> prefixes.any(d::startsWith) } == true
    }

internal fun AccessibilityNodeInfo.hasSelectedDescPrefix(prefixes: List<String>) =
    findSelectedDescPrefix(prefixes) != null
