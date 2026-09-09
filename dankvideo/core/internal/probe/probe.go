package probe

import (
	"encoding/json"
	"os"
	"os/exec"
	"path/filepath"
	"strconv"
)

type MediaInfo struct {
	FilePath   string       `json:"filePath"`
	FileName   string       `json:"fileName"`
	FileSize   int64        `json:"fileSize"`
	Directory  string       `json:"directory"`
	Duration   float64      `json:"duration"`
	Width      int          `json:"width"`
	Height     int          `json:"height"`
	VideoCodec string       `json:"videoCodec"`
	AudioCodec string       `json:"audioCodec"`
	Bitrate    int64        `json:"bitrate"`
	Streams    []StreamInfo `json:"streams,omitempty"`
}

type StreamInfo struct {
	Index     int    `json:"index"`
	CodecType string `json:"codecType"`
	CodecName string `json:"codecName"`
	Width     int    `json:"width,omitempty"`
	Height    int    `json:"height,omitempty"`
	Channels  int    `json:"channels,omitempty"`
	Language  string `json:"language,omitempty"`
}

type ffprobeFormat struct {
	Filename string `json:"filename"`
	Duration string `json:"duration"`
	Size     string `json:"size"`
	BitRate  string `json:"bit_rate"`
}

type ffprobeStream struct {
	Index     int               `json:"index"`
	CodecType string            `json:"codec_type"`
	CodecName string            `json:"codec_name"`
	Width     int               `json:"width"`
	Height    int               `json:"height"`
	Channels  int               `json:"channels"`
	Tags      map[string]string `json:"tags"`
}

type ffprobeOutput struct {
	Streams []ffprobeStream `json:"streams"`
	Format  ffprobeFormat   `json:"format"`
}

func GetMediaInfo(filePath string) (*MediaInfo, error) {
	absPath, err := filepath.Abs(filePath)
	if err != nil {
		return nil, err
	}

	fi, err := os.Stat(absPath)
	if err != nil {
		return nil, err
	}

	info := &MediaInfo{
		FilePath:  absPath,
		FileName:  filepath.Base(absPath),
		FileSize:  fi.Size(),
		Directory: filepath.Dir(absPath),
	}

	// Try probing with ffprobe if available
	cmd := exec.Command("ffprobe",
		"-v", "quiet",
		"-print_format", "json",
		"-show_format",
		"-show_streams",
		absPath,
	)

	out, err := cmd.Output()
	if err == nil {
		var probeOut ffprobeOutput
		if err := json.Unmarshal(out, &probeOut); err == nil {
			if d, err := strconv.ParseFloat(probeOut.Format.Duration, 64); err == nil {
				info.Duration = d
			}
			if b, err := strconv.ParseInt(probeOut.Format.BitRate, 10, 64); err == nil {
				info.Bitrate = b
			}

			for _, s := range probeOut.Streams {
				st := StreamInfo{
					Index:     s.Index,
					CodecType: s.CodecType,
					CodecName: s.CodecName,
					Width:     s.Width,
					Height:    s.Height,
					Channels:  s.Channels,
				}
				if s.Tags != nil {
					st.Language = s.Tags["language"]
				}
				info.Streams = append(info.Streams, st)

				if s.CodecType == "video" && info.VideoCodec == "" {
					info.VideoCodec = s.CodecName
					info.Width = s.Width
					info.Height = s.Height
				} else if s.CodecType == "audio" && info.AudioCodec == "" {
					info.AudioCodec = s.CodecName
				}
			}
		}
	} else {
		// Fallback without ffprobe: basic file info
		info.VideoCodec = "unknown"
	}

	return info, nil
}
