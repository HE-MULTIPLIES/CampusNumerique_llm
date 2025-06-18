"""
Vocal Assistant Core - CLI

A tool to transform audio recordings into structured data and PDF reports.

Usage:
    poetry run python main.py <command> [options]

Commands:
    speech_to_text    - Convert audio file to text
    text_extraction   - Extract structured data from text
    pdf_generation    - Generate PDF from structured data
    convert-audio     - Convert .m4a audio files to .mp3 format
    full_processing   - Run the complete pipeline (future feature)
"""
import argparse
import os

from config.logging_config import setup_logging
from core.speech_to_text import AudioFileConverter, GoogleSpeechToText, OpenaiSpeechToText
from core.text_extraction.CrConsultationExtractor import CrConsultationExtractor

logger = setup_logging(__name__)

def setup_config():
    """Create or update the configuration file"""
    cmd = "python settings/make_ini.py"  # Creates config.ini with all necessary paths
    os.system(cmd)

def run_convert_audio(args: argparse.Namespace) -> None:
    """Convert .m4a audio files to .mp3 format"""
    # Get the subfolder argument if provided
    extra_options = vars(args)
    subfolder = extra_options.get('subfolder')
    extra_options.pop('func', None)

    logger.info(f"Starting audio conversion{f' in subfolder: {subfolder}' if subfolder else ''}")

    # Create the converter and run the conversion
    converter = AudioFileConverter()
    converted_files = converter.convert_all(subfolder=subfolder)

    # Print results
    if converted_files:
        logger.info(f"Successfully converted {len(converted_files)} files:")
        for file in converted_files:
            logger.info(f"  - {file}")
    else:
        logger.info("No files were converted. Check if there are any .m4a files in the target directory.")

def run_speech_to_text(args: argparse.Namespace) -> None:
    """Run the speech-to-text conversion process"""
    # Convert any provided options to a dictionary for kwargs
    extra_options = vars(args)
    # Remove parameters from kwargs as they'll be passed separately
    file_name = extra_options.pop('file_name', None)
    pdf_type = extra_options.pop('pdf_type', None)
    extra_options.pop('func', None)

    logger.info(f"Running speech-to-text conversion for file: {file_name} with PDF type: {pdf_type}")
    if extra_options.get('model') == 'openai':
        OpenaiSpeechToText(pdf_type, file_name).run()
    elif extra_options.get('model') == 'google':
        GoogleSpeechToText(pdf_type, file_name).run()

def run_cr_consultation(args: argparse.Namespace) -> None:
    """Run the CR consultation text extraction process"""
    # Extract the filename argument
    filename = args.filename

    logger.info(f"Running CR consultation text extraction for file: {filename}")

    # Create the extractor and run the n8n process
    try:
        extractor = CrConsultationExtractor(filename)
        result = extractor.post_n8n_request()
        logger.info(f"Successfully processed file {filename}")
        logger.info(f"Response from n8n: {result}")
    except Exception as e:
        logger.error(f"Failed to process file {filename}: {e!s}")
        raise


def create_parser() -> argparse.ArgumentParser:
    """Create the command-line argument parser"""
    # Create the top-level parser
    parser = argparse.ArgumentParser(
        description="Vocal Assistant Core - Process audio files into structured data and PDF reports",
        formatter_class=argparse.RawDescriptionHelpFormatter
    )

    # Create subparsers for each command
    subparsers = parser.add_subparsers(dest='command', help='Command to execute')
    subparsers.required = True

    # convert-audio command
    convert_parser = subparsers.add_parser('convert-audio', help='Convert .m4a audio files to .mp3 format')
    convert_parser.add_argument('--subfolder', help='Optional subfolder to process (e.g., 01_cr_consultation)')
    convert_parser.set_defaults(func=run_convert_audio)

    # speech_to_text command
    stt_parser = subparsers.add_parser('speech_to_text', help='Convert audio file to text')
    stt_parser.add_argument('pdf_type', help='Type of PDF/document (e.g., cr_consultation)')
    stt_parser.add_argument('file_name', help='Audio file name to process')
    stt_parser.add_argument('--model', choices=['openai', 'google'], default='openai',
                           help='Speech-to-text model to use (default: openai)')
    stt_parser.set_defaults(func=run_speech_to_text)

    # cr_consultation command
    cr_consultation_parser = subparsers.add_parser('cr_consultation', help='Extract structured data from CR consultation text file')
    cr_consultation_parser.add_argument('filename', help='Text file name to process')
    cr_consultation_parser.set_defaults(func=run_cr_consultation)

    return parser


def main() -> None:
    """Main entry point for the CLI"""
    # Setup configuration
    setup_config()

    # Parse arguments
    parser = create_parser()
    args = parser.parse_args()

    # Execute the appropriate command
    if hasattr(args, 'func'):
        args.func(args)
    else:
        parser.print_help()


if __name__ == "__main__":
    main()

