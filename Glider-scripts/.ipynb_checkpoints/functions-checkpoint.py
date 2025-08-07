import pandas as pd
import re
import matplotlib.pyplot as plt


def parse_roll_log(fpath):
    data = []

    with open(fpath, "r") as file:
        lines = file.readlines()

    for line in lines:
        line = line.strip()
        if not line:
            continue

        try:
            filename, rest = line.split(":", 1)
            timestamp_str, rest = rest.split(",", 1)
            timestamp = float(timestamp_str)
        except ValueError:
            continue  # skip malformed lines

        if "Roll commanded from" in rest:
            match = re.search(r"Roll commanded from ([\-\d.]+) deg.* to ([\-\d.]+) deg", rest)
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "commanded",
                    "start_deg": float(match.group(1)),
                    "end_deg": float(match.group(2)),
                })

        elif "Roll: No motion occurred." in rest:
            data.append({
                "filename": filename,
                "timestamp": timestamp,
                "event_type": "no_motion",
            })

        elif "Roll completed from" in rest:
            match = re.search(
                r"Roll completed from ([\-\d.]+) deg.* to ([\-\d.]+) deg.* took ([\d.]+) sec (\d+) mA \((\d+) mA peak\) ([\d.]+) Vmin ([\d.]+) AD/sec (\d+) ticks",
                rest
            )
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "completed",
                    "start_deg": float(match.group(1)),
                    "end_deg": float(match.group(2)),
                    "duration_sec": float(match.group(3)),
                    "avg_current_mA": int(match.group(4)),
                    "peak_current_mA": int(match.group(5)),
                    "vmin": float(match.group(6)),
                    "ad_per_sec": float(match.group(7)),
                    "ticks": int(match.group(8)),
                })

    return pd.DataFrame(data)

def parse_pump_log(fpath):
    with open(fpath, "r") as file:
        lines = file.readlines()

    data = []

    for line in lines:
        filename, rest = line.strip().split(":", 1)
        timestamp_str, rest = rest.split(",", 1)
        timestamp = float(timestamp_str)

        # Pump commanded
        if "Pump commanded from" in rest:
            match = re.search(r"Pump commanded from ([\-\d.]+) cc.* to ([\-\d.]+) cc", rest)
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "commanded",
                    "start_cc": float(match.group(1)),
                    "end_cc": float(match.group(2)),
                })

        # Pump completed
        elif "Pump completed from" in rest:
            match = re.search(
                r"Pump completed from ([\-\d.]+) cc.* to ([\-\d.]+) cc.* took ([\d.]+) sec (\d+) mA \((\d+) mA peak\) ([\d.]+) Vmin ([\d.]+) AD/sec (\d+) ticks",
                rest
            )
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "completed",
                    "start_cc": float(match.group(1)),
                    "end_cc": float(match.group(2)),
                    "duration_sec": float(match.group(3)),
                    "avg_current_mA": int(match.group(4)),
                    "peak_current_mA": int(match.group(5)),
                    "vmin": float(match.group(6)),
                    "ad_per_sec": float(match.group(7)),
                    "ticks": int(match.group(8)),
                })

    return pd.DataFrame(data)

def plot_ad_vs_duration(df):
    # Filter only 'completed' events
    completed_df = df[df["event_type"] == "completed"].copy()

    # Create labels for each data point
    completed_df["label"] = completed_df.apply(
        lambda row: f"{row['start_cc']} → {row['end_cc']}", axis=1
    )

    # Create scatter plot
    plt.figure(figsize=(12, 6))
    plt.scatter(completed_df["duration_sec"], completed_df["ad_per_sec"], color='blue')

    # Add labels
    for _, row in completed_df.iterrows():
        plt.text(row["duration_sec"], row["ad_per_sec"], row["label"], fontsize=8, ha='right', va='bottom')

    # Plot formatting
    plt.title("AD/sec vs Duration for Pump Completions")
    plt.xlabel("Duration (sec)")
    plt.ylabel("AD/sec")
    plt.grid(True)
    plt.tight_layout()
    plt.show()

import matplotlib.pyplot as plt

def plot_ad_vs_current_with_labels(df):
    # Filter to only rows that have the required data
    required_cols = {"ad_per_sec", "avg_current_mA", "start_deg", "end_deg"}
    if not required_cols.issubset(df.columns):
        raise ValueError("DataFrame must contain columns: ad_per_sec, avg_current_mA, start_deg, end_deg")

    plt.figure(figsize=(10, 6))
    plt.scatter(df["ad_per_sec"], df["avg_current_mA"], color='blue')

    # Add labels to each point
    for _, row in df.iterrows():
        label = f'{row["start_deg"]}°→{row["end_deg"]}°'
        plt.annotate(label, (row["ad_per_sec"], row["avg_current_mA"]),
                     textcoords="offset points", xytext=(5,5), ha='left', fontsize=8)

    # Labels and formatting
    plt.xlabel("AD per sec")
    plt.ylabel("Avg Current (mA)")
    plt.title("AD per sec vs Avg Current (Labeled by Start→End Degrees)")
    plt.grid(True)
    plt.tight_layout()
    plt.show()


def parse_pitch_log(filepath):
    """Parses pitch log text file and returns a DataFrame of events."""
    data = []

    with open(filepath, "r") as file:
        lines = file.readlines()

    for line in lines:
        try:
            filename, rest = line.strip().split(":", 1)
            timestamp_str, rest = rest.split(",", 1)
            timestamp = float(timestamp_str)
        except ValueError:
            continue  # Skip malformed lines

        if "Pitch commanded from" in rest:
            match = re.search(r"Pitch commanded from ([\-\d.]+) cm.* to ([\-\d.]+) cm", rest)
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "commanded",
                    "start_cm": float(match.group(1)),
                    "end_cm": float(match.group(2)),
                })

        elif "Pitch: No motion occurred." in rest:
            data.append({
                "filename": filename,
                "timestamp": timestamp,
                "event_type": "no_motion",
            })

        elif "Pitch completed from" in rest:
            match = re.search(
                r"Pitch completed from ([\-\d.]+) cm.* to ([\-\d.]+) cm.* took ([\d.]+) sec (\d+) mA \((\d+) mA peak\) ([\d.]+) Vmin ([\d.]+) AD/sec (\d+) ticks",
                rest
            )
            if match:
                data.append({
                    "filename": filename,
                    "timestamp": timestamp,
                    "event_type": "completed",
                    "start_cm": float(match.group(1)),
                    "end_cm": float(match.group(2)),
                    "duration_sec": float(match.group(3)),
                    "avg_current_mA": int(match.group(4)),
                    "peak_current_mA": int(match.group(5)),
                    "vmin": float(match.group(6)),
                    "ad_per_sec": float(match.group(7)),
                    "ticks": int(match.group(8)),
                })

    return pd.DataFrame(data)

def plot_pitch_ad_vs_current(df):
    """Plots AD/sec vs Avg Current with labels showing start → end cm."""
    completed = df[df["event_type"] == "completed"].copy()
    if completed.empty:
        print("No completed pitch events to plot.")
        return

    # Label for each point
    completed["label"] = completed.apply(
        lambda row: f'{row["start_cm"]}→{row["end_cm"]}', axis=1
    )

    # Plot
    plt.figure(figsize=(10, 6))
    plt.scatter(completed["ad_per_sec"], completed["avg_current_mA"], color='green')

    for _, row in completed.iterrows():
        plt.annotate(row["label"], (row["ad_per_sec"], row["avg_current_mA"]),
                     textcoords="offset points", xytext=(5,5), ha='left', fontsize=8)

    plt.xlabel("AD per sec")
    plt.ylabel("Avg Current (mA)")
    plt.title("AD/sec vs Avg Current for Pitch (Labeled by Start→End cm)")
    plt.grid(True)
    plt.tight_layout()
    plt.show()
