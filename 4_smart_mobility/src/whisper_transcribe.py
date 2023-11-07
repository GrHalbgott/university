#!/usr/bin/env python
# -*- coding: utf-8 -*-
"""Queries the Whisper AI for transcription"""

import sys
import whisper
from pathlib import Path

in_dir = Path("./interview/")
f_name = "Interview_cut"

model = whisper.load_model("medium")

result = model.transcribe(in_dir / f"{f_name}.mp3", verbose=False)

with open(in_dir / f"{f_name}.txt", "w", encoding="utf-8") as f:
    f.write(result["text"])

sys.exit("FINISHED.")
    