package com.typ.chat_bot.actions

import android.content.Context
import android.util.Log
import com.typ.chat_bot.ai.ActionTextClassifier

class ActionIdentifier(context: Context) {

    private val classifier = ActionTextClassifier(context)

    fun identifyAction(text: String, callback: (Action?, String?) -> Unit) {
        try {
            classifier.classify(text) { result, error ->
                // Check if has error at first
                if (error != null || result == null) {
                    Log.e(TAG, "identifyAction: Error => $error")
                    callback(null, error)
                    return@classify
                }
                // Handle the result
                val rawResult = result.classificationResult()
                    .classifications()
                    .first()
                    .categories().maxByOrNull { it.score() }

                rawResult?.let { raw ->
                    Log.d(TAG, "identified action: ${raw.categoryName()} with score: ${raw.score()}")
                    callback(Action(raw.categoryName()), null)
                } ?: run {
                    Log.e(TAG, "identifyAction: Action not found.")
                    callback(null, "Action not found.")
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "identifyAction: Exception => ${e.message}")
            callback(null, "Exception: ${e.message}")
        }
    }

    companion object {
        const val TAG = "ActionIdentifier"
    }
}
