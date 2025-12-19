#!/bin/bash

sudo systemctl enable --now linux-modules-cleanup.service
systemctl --user enable --now yaycache.timer
